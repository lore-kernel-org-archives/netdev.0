From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_sched: make traffic control network namespace aware
Date: Mon, 22 Mar 2010 20:26:54 -0700 (PDT)
Message-ID: <20100322.202654.191159569.davem@davemloft.net>
References: <20100320014013.GC13239@boeing.com>
	<4BA7AF32.8020001@trash.net>
	<4BA7B13C.7020304@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.goff@boeing.com, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37694
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752539Ab0CWD0b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 23:26:31 -0400
In-Reply-To: <4BA7B13C.7020304@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 22 Mar 2010 19:04:44 +0100

> Patrick McHardy wrote:
>> Tom Goff wrote:
>>> Mostly minor changes to add a net argument to various functions and
>>> remove initial network namespace checks.
>>>
>>> Make /proc/net/psched per network namespace.
>> 
>> Looks fine from a qdisc POV. One thing that appears to be missing
>> though is teql master netdev registration in other than the initial
>> namespace.
> 
> Actually we could take this opportunity and add rtnl_link support
> for teql device registration. I can look into this in a couple of
> days.

I've applied Tom's patch to net-next-2.6, thanks everyone.
