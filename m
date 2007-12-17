From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] bridge: assign random address
Date: Sun, 16 Dec 2007 20:46:24 -0500
Message-ID: <4765D4F0.5040202@garzik.org>
References: <20071211154835.75ace6bc@freepuppy.rosehill>	<20071216.133717.202852113.davem@davemloft.net>	<20071216142915.c120d25c.akpm@linux-foundation.org> <20071216.152606.35263254.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	berrange@redhat.com, herbert@gondor.apana.org.au, rjw@sisk.pl
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39796 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759620AbXLQBqj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Dec 2007 20:46:39 -0500
In-Reply-To: <20071216.152606.35263254.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Sun, 16 Dec 2007 14:29:15 -0800
> 
>> On Sun, 16 Dec 2007 13:37:17 -0800 (PST) David Miller <davem@davemloft.net> wrote:
>>
>>> From: Stephen Hemminger <shemminger@linux-foundation.org>
>>> Date: Tue, 11 Dec 2007 15:48:35 -0800
>>>
>>>> Subject: Re: [PATCH] bridge: assign random address
>>> "bridge" should all-caps and in brackets,
>> No, "bridge" should not be in [].  Lots of people's patch-receiving scripts
>> assume that any text in [] is to be removed as the patch is committed.  It
>> contains text which is only relevant to the particular email which carried
>> the patch.  Stuff like "patch" and "4/5" and "linux-2.6.23", etc.
> 
> I don't use scripts, I edit it by hand.  And when I do ever use
> scripts I will make sure they accomodate "[$SUBSYSTEM]" format
> subject lines, you can be sure.
> 
> And you can even make those scripts happy by doing:
> 
> [Patch 1/7] [SUBSYSTEM]: Foo bar baz...

The most popular tool is git-am, which I and many others use.

git-am will snip "[SUBSYSTEM]" in the example that you give.

Until Linus's official mail import tool (git-am) changes, I agree with 
Andrew -- since Andrew is simply describing the de facto standard as it 
exists today:  [] gets eaten.

That's why documentation like Documentation/SubmittingPatches and 
http://linux.yyz.us/patch-format.html indicate "subsystem: " rather than 
"[SUBSYSTEM]":  it's compatible with Linus's widely used mail import tool.

	Jeff




