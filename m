From: David Miller <davem@davemloft.net>
Subject: Re: Seeing new kernel unaligned access messages in linux-next on
 ia64
Date: Sat, 27 Mar 2010 17:17:15 -0700 (PDT)
Message-ID: <20100327.171715.232746020.davem@davemloft.net>
References: <alpine.LSU.2.01.1003271313230.2740@obet.zrqbmnf.qr>
	<20100327.163730.179928738.davem@davemloft.net>
	<alpine.LSU.2.01.1003280107420.14977@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: schwab@linux-m68k.org, tony.luck@intel.com, netdev@vger.kernel.org
To: jengelh@medozas.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55253
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754291Ab0C1AQw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Mar 2010 20:16:52 -0400
In-Reply-To: <alpine.LSU.2.01.1003280107420.14977@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>
Date: Sun, 28 Mar 2010 01:11:13 +0100 (CET)

> On Sunday 2010-03-28 00:37, David Miller wrote:
>>
>>> net: fix unaligned access in IFLA_STATS64
>>
>>Applied to net-next-2.6, thanks Jan.
>>
>>Hey, don't we need some adjustments to if_nlmsg_size()?  I don't see
>>it accounting for IFLA_STATS64/"struct rtnl_link_stats64" there.
> 
> If I am not mistaken, the answer is "not strictly". But of course it's 
> nicer if we don't need to realloc just because we were too conservative 
> in the initial calculation.

Right.

> net: increase preallocated size of nlmsg to accomodate for IFLA_STATS64
> 
> When more data is stuffed into an nlmsg than initially projected, an
> extra allocation needs to be done. Reserve enough for IFLA_STATS64 so
> that this does not to needlessy happen.
> 
> Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

Applied, thanks a lot!
