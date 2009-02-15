From: Hannes Eder <hannes@hanneseder.net>
Subject: Re: [PATCH 31/43] drivers/net/tokenring: fix sparse warning: cast
	truncates bits from const value
Date: Sun, 15 Feb 2009 12:47:42 +0100
Message-ID: <154e089b0902150347o4e06683dy1c9c02dc2564ea4f@mail.gmail.com>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
	 <20090214214452.24377.31953.stgit@vmbox.hanneseder.net>
	 <20090214232448.GR28946@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Al Viro <viro@zeniv.linux.org.uk>, Jay Schulist <jschlst@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f25.google.com ([209.85.220.25]:55616 "EHLO
	mail-fx0-f25.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751582AbZBOLrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2009 06:47:46 -0500
In-Reply-To: <20090214232448.GR28946@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 15, 2009 at 12:24 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Sat, Feb 14, 2009 at 10:46:24PM +0100, Hannes Eder wrote:
>> Impact: Use '__u16' instead of '__u8', this possibly fixes a bug.
>>
>> Fix this sparse warnings:
>>   drivers/net/tokenring/smctr.c:4410:52: warning: cast truncates bits from constant value (100 becomes 0)
>>   drivers/net/tokenring/smctr.c:4415:52: warning: cast truncates bits from constant value (400 becomes 0)
>>   drivers/net/tokenring/smctr.c:4420:52: warning: cast truncates bits from constant value (800 becomes 0)
>>   drivers/net/tokenring/smctr.c:4425:52: warning: cast truncates bits from constant value (1000 becomes 0)
>>   drivers/net/tokenring/smctr.c:4430:52: warning: cast truncates bits from constant value (2000 becomes 0)
>>   drivers/net/tokenring/smctr.c:4435:52: warning: cast truncates bits from constant value (4000 becomes 0)
>>   drivers/net/tokenring/smctr.c:4440:52: warning: cast truncates bits from constant value (8000 becomes 0)
>
> Um, no.  Here's a better question: does *anything* use ->current_ring_status
> at all?  Answer: no.  Next question: did anything use it in the past?
> git log -p drivers/net/tokenging/smctr.c in historical trees shows that
> it had always been defined that way and that it had never been used at
> all.
>
> So how about removing the damn field completely?  Or asking the driver's
> author what the hell had it been about?
>

I vote for removing the field, I prepare a patch for this.

Comments?

-Hannes
