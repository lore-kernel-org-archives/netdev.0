From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH] tun: allow setting ethernet addresss while running
Date: Wed, 12 Dec 2012 04:27:54 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1212120427370.16297@nerf07.vanv.qr>
References: <1355188560-8388-1-git-send-email-shemminger@vyatta.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, netdev@vger.kernel.org, jasowang@redhat.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares07.inai.de ([5.9.24.206]:51031 "EHLO ares07.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754458Ab2LLD14 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Dec 2012 22:27:56 -0500
In-Reply-To: <1355188560-8388-1-git-send-email-shemminger@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 2012-12-11 02:16, Stephen Hemminger wrote:

>This is a pure software device, and ok with live address change.
>--- a/drivers/net/tun.c
>+++ b/drivers/net/tun.c
>@@ -849,6 +849,7 @@ static void tun_net_init(struct net_device *dev)
> 		/* Ethernet TAP Device */
> 		ether_setup(dev);
> 		dev->priv_flags &= ~IFF_TX_SKB_SHARING;
>+		dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
> 
> 		eth_hw_addr_random(dev);

Would this possibly apply to L2TP devices as well?
