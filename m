From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix NULL reference in proxy neighbor discovery
Date: Fri, 25 Jun 2010 21:31:04 -0700 (PDT)
Message-ID: <20100625.213104.71566967.davem@davemloft.net>
References: <20100621102508.2075d677@nehalam>
	<20100621200413.GA2280@EIS>
	<20100621140013.508741df@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Andreas.Klauer@metamorpher.de, hagen@jauu.net,
	netdev@vger.kernel.org, opurdila@ixiacom.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36980
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750983Ab0FZEaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jun 2010 00:30:52 -0400
In-Reply-To: <20100621140013.508741df@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 21 Jun 2010 14:00:13 -0700

> The addition of TLLAO option created a kernel OOPS regression
> for the case where neighbor advertisement is being sent via
> proxy path.  When using proxy, ipv6_get_ifaddr() returns NULL
> causing the NULL dereference.
> 
> Change causing the bug was:
> commit f7734fdf61ec6bb848e0bafc1fb8bad2c124bb50
> Author: Octavian Purdila <opurdila@ixiacom.com>
> Date:   Fri Oct 2 11:39:15 2009 +0000
> 
>     make TLLAO option for NA packets configurable
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks.
