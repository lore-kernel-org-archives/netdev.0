From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH] net/can/mscan: Enable interrupts when all TX buffers
 are occupied to get notified when they are available again
Date: Mon, 28 Nov 2011 15:22:29 +0100
Message-ID: <4ED39925.7080606@grandegger.com>
References: <C3745E3C7FD07D429C54EB3D7606A5A7677E7C@ZRHEX021.ads.zuehlke.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"socketcan@hartkopp.net" <socketcan@hartkopp.net>,
	"lucas.demarchi@profusion.mobi" <lucas.demarchi@profusion.mobi>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"mkl@pengutronix.de" <mkl@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Mosler, Martin" <mmo@zuehlke.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ngcobalt02.manitu.net ([217.11.48.102]:53485 "EHLO
	ngcobalt02.manitu.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751034Ab1K1OWc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 09:22:32 -0500
In-Reply-To: <C3745E3C7FD07D429C54EB3D7606A5A7677E7C@ZRHEX021.ads.zuehlke.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/28/2011 02:25 PM, Mosler, Martin wrote:
> When all TX buffers of the mscan are occupied the network layer is told to stop sending further packets. However the TX interrupts are not enabled and therefore the driver has no chance to tell the network layer when it is ready to accept further packets.

Please break lines after 72 chars, or so.

> Signed-off-by: Martin Mosler <mmo@zuehlke.com>
> 
> --- linux-2.6/drivers/net/can/mscan/mscan.c.orig    2011-11-28 13:54:29.547850661 +0100
> +++ linux-2.6/drivers/net/can/mscan/mscan.c 2011-11-28 13:55:52.427849601 +0100
> @@ -214,6 +214,7 @@ static netdev_tx_t mscan_start_xmit(stru
>     case 0:
>         netif_stop_queue(dev);
>         dev_err(dev->dev.parent, "Tx Ring full when queue awake!\n");
> +       out_8(&regs->cantier, priv->tx_active);
>         return NETDEV_TX_BUSY;
>     case 1:
>         /*  

I cannot apply this patch. It is white space mangled (no tabs but
spaces, etc.). Please fix your mail agent or, even better, use "git
send-email".

Wolfgang.
