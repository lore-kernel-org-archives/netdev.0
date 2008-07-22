From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Fix typo in meth driver
Date: Tue, 22 Jul 2008 19:39:40 -0400
Message-ID: <48866FBC.1030008@garzik.org>
References: <4877CCC2.5050702@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kay Sievers <kay.sievers@vrfy.org>, netdev@vger.kernel.org
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49880 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756834AbYGVXjs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2008 19:39:48 -0400
In-Reply-To: <4877CCC2.5050702@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter wrote:
> An | in an if statement to check a bit? I think this needs to be a &.
> As a result of this typo meth will always operate in promiscuous mode.
> 
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
> 
> Index: linux-2.6/drivers/net/meth.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/meth.c	2008-07-11 16:05:00.000000000 -0500
> +++ linux-2.6/drivers/net/meth.c	2008-07-11 16:05:02.000000000 -0500
> @@ -287,7 +287,7 @@
>  
>  	/* Initial mode: 10 | Half-duplex | Accept normal packets */
>  	priv->mac_ctrl = METH_ACCEPT_MCAST | METH_DEFAULT_IPG;
> -	if (dev->flags | IFF_PROMISC)
> +	if (dev->flags & IFF_PROMISC)
>  		priv->mac_ctrl |= METH_PROMISC;
>  	mace->eth.mac_ctrl = priv->mac_ctrl;
>  

applied


