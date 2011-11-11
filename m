From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH] r8169: more driver shutdown WoL regression.
Date: Fri, 11 Nov 2011 16:37:20 +0800
Message-ID: <0ABF12A38A18494E9A53BE529370F974@realtek.com.tw>
References: <20111108223502.GA20437@electric-eye.fr.zoreil.com> <E6A5E7482020466E82FD141C8CD92D9A@realtek.com.tw> <20111109222556.GA8226@electric-eye.fr.zoreil.com> <DCB55CA56A5546B4B7350912D30EC679@realtek.com.tw> <20111110104117.GA23906@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, 'Stefan Becker' <chemobejk@gmail.com>,
	'David Miller' <davem@davemloft.net>,
	'Ben Hutchings' <bhutchings@solarflare.com>
To: 'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:55060 "EHLO
	rtits2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754130Ab1KKIhl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2011 03:37:41 -0500
In-Reply-To: <20111110104117.GA23906@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu [mailto:romieu@fr.zoreil.com] 
[...]
> 
> Hayes, should I consider similar cross-behaviors between 
> RxConfig and WoL
> ConfigX bits with different configurations ?
> 
> I.e., assuming Config5.UWF is active and Config3.MagicPacket 
> is not, can
> RxConfig.AcceptMyPhys make a difference to the WoL function ?
> 

Yes. The RxConfig influences if you could receive unicast, multicast, or
broadcast packets. If you don't enable the relative bits of RxConfig, the WOL
feature won't  work no matter which WOL mode you set.

> > Further, it may be dangerous to enable both rx_enable 
> (ChipCmd bit 3) and
> > RxConfig for 8168b for WOL, because the hw would try to 
> write the rx buffer.
> 
> Ok.
> 
 
Best Regards,
Hayes
