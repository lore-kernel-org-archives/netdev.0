From: Florian Fainelli <florian.fainelli@telecomint.eu>
Subject: Re: [PATCH] [NET] uli526x: add support for netpoll
Date: Thu, 15 May 2008 22:51:23 +0200
Message-ID: <200805152251.24137.florian.fainelli@telecomint.eu>
References: <20080515151255.GA12408@polina.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Anton Vorontsov <avorontsov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.int-evry.fr ([157.159.10.71]:58502 "EHLO
	smtp4.int-evry.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752177AbYEOUve convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 16:51:34 -0400
In-Reply-To: <20080515151255.GA12408@polina.dev.rtsoft.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Anton,

Le Thursday 15 May 2008 17:12:55 Anton Vorontsov, vous avez =C3=A9crit=C2=
=A0:
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +static void uli526x_poll(struct net_device *dev)
> +{
> +	/* ISR grabs the irqsave lock, so this should be safe */
> +	uli526x_interrupt(dev->irq, dev);
> +}
> +#endif

You do not need to wrap this function into the ifdef, since setting the=
 poll=20
callback is between ifdef. Otherwise patch looks good.
--=20
Cordialement, Florian Fainelli
------------------------------
