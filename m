From: "Paul Marks" <paul@pmarks.net>
Subject: Re: When should kfree_skb be used?
Date: Thu, 8 May 2008 23:55:41 -0700
Message-ID: <8e5b27790805082355x968c4e3p1d40f3acfec3f123@mail.gmail.com>
References: <8e5b27790805082149y6d9f604ds7feefe2804f3823c@mail.gmail.com>
	 <8e5b27790805082334g6c5a1752pd42ab291ac6b33af@mail.gmail.com>
	 <20080508.234122.20422788.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:31631 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751539AbYEIGz4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 02:55:56 -0400
Received: by yw-out-2324.google.com with SMTP id 9so644205ywe.1
        for <netdev@vger.kernel.org>; Thu, 08 May 2008 23:55:41 -0700 (PDT)
In-Reply-To: <20080508.234122.20422788.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 8, 2008 at 11:41 PM, David Miller <davem@davemloft.net> wrote:
> From: "Paul Marks" <paul@pmarks.net>
> Date: Thu, 8 May 2008 23:34:59 -0700
>
>> I've been looking at more uses of pskb_may_pull(), and almost all of
>> them seem to kfree_skb() after a failure.  Could this occurence in
>> sit.c be a bug?  It looks like this line was added by davem for linux
>> 2.4.4 in 2001, and hasn't changed since.
>
> Yep, looks like a leak.  The following should fix it, thanks
> for the report:
>

Ok, cool, that makes more sense now.
