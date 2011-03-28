From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2 v2] tg3: Don't use IRQF_SAMPLE_RANDOM
Date: Mon, 28 Mar 2011 14:25:52 +0200
Message-ID: <1301315152.3182.19.camel@edumazet-laptop>
References: <1301314543-3666-1-git-send-email-martinez.javier@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Dan Carpenter <error27@gmail.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Javier Martinez Canillas <martinez.javier@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:54530 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751008Ab1C1MZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2011 08:25:57 -0400
In-Reply-To: <1301314543-3666-1-git-send-email-martinez.javier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 28 mars 2011 =C3=A0 14:15 +0200, Javier Martinez Canillas a =C3=
=A9crit :
> This flag is scheduled for removal so we shouldn't used it.
>=20
> Signed-off-by: Javier Martinez Canillas <martinez.javier@gmail.com>
> ---
> v2: Initialize flags to zero suggested by Dan Carpenter.
>=20
>  drivers/net/tg3.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)

1) We dont believe its Janitor material ;)

http://thread.gmane.org/gmane.linux.kernel/680723

http://kerneltrap.org/mailarchive/linux-netdev/2009/4/6/5417754

2) If removal is accepted, we should patch all drivers at once

drivers/net/xen-netfront.c:1419:					IRQF_SAMPLE_RANDOM, netdev->name,
drivers/net/cris/eth_v10.c:495:			IRQF_SAMPLE_RANDOM, cardname, (void *=
)dev)) {
drivers/net/ibmlana.c:785:	result =3D request_irq(priv->realirq, irq_ha=
ndler, IRQF_SHARED | IRQF_SAMPLE_RANDOM, dev->name, dev);
drivers/net/qla3xxx.c:3471:	unsigned long irq_flags =3D IRQF_SAMPLE_RAN=
DOM | IRQF_SHARED;
drivers/net/netxen/netxen_nic_main.c:908:	unsigned long flags =3D IRQF_=
SAMPLE_RANDOM;
drivers/net/atlx/atl1.c:2575:	int irq_flags =3D IRQF_SAMPLE_RANDOM;
drivers/net/macb.c:1174:	err =3D request_irq(dev->irq, macb_interrupt, =
IRQF_SAMPLE_RANDOM,
drivers/net/bcm63xx_enet.c:843:			  IRQF_SAMPLE_RANDOM | IRQF_DISABLED,=
 dev->name, dev);
drivers/net/niu.c:6075:				  IRQF_SHARED | IRQF_SAMPLE_RANDOM,
drivers/net/tg3.c:8842:		flags =3D IRQF_SAMPLE_RANDOM;


