From: Cord Walter <cord.walter@gmx.de>
Subject: pcnet_cs: fix misuse of the equality operator.
Date: Sun, 01 Feb 2009 00:18:40 +0100
Message-ID: <4984DC50.6060204@gmx.de>
References: <4925F6F1.9010305@gmx.de>	<20081121214812.b03d7166.komurojun-mbn@nifty.com>	<4926C153.3090104@gmx.de>	<20081124160959.b02ff889.komurojun-mbn@nifty.com>	<492BE6DE.9020903@gmx.de> <20090131071342.2b45cbe8.komurojun-mbn@nifty.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from waikiki.ops.eusc.inter.net ([84.23.254.155]:64666 "EHLO
	waikiki.ops.eusc.inter.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751380AbZAaXni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2009 18:43:38 -0500
Received: from myip-n72-220.de.inter.net ([213.73.72.220] helo=rei.cwalter.net)
	by waikiki.ops.eusc.inter.net with esmtp (Exim 4.69)
	id 1LTP6m-000Iml-Gq
	for netdev@vger.kernel.org; Sun, 01 Feb 2009 00:18:40 +0100
Received: from [10.42.42.2] (nene.cwalter.net [10.42.42.2])
	by rei.cwalter.net (Postfix) with ESMTP id 69F3B1BE5F
	for <netdev@vger.kernel.org>; Sun,  1 Feb 2009 00:18:39 +0100 (CET)
In-Reply-To: <20090131071342.2b45cbe8.komurojun-mbn@nifty.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

I just noticed that I still had a patch lying around by Komuro
<komurojun-mbn@nifty.com> from back when I was troubleshooting my
problems with the pcnet_cs/axnet_cs driver and my Netgear PCMCIA-NIC.

Looks like a simple typo to me - I tested the patch with 2.6.28 kernel
and it worked...

bye,

cord

Komuro schrieb:
 > [PATCH] pcnet_cs:fix misuse of the equality operator.
>=20
>=20
> pcnet_cs:
> 	fix misuse of the equality operator.
>=20
> =20
> Signed-off-by: Cord Walter <qord@cwalter.net>
> Signed-off-by: Komuro <komurojun-mbn@nifty.com>
>=20
> ---
>=20
> --- linux-2.6.29-rc3/drivers/net/pcmcia/pcnet_cs.c.orig	2009-01-31 06=
:44:03.000000000 +0900
> +++ linux-2.6.29-rc3/drivers/net/pcmcia/pcnet_cs.c	2009-01-31 06:44:2=
1.000000000 +0900
> @@ -586,7 +586,7 @@ static int pcnet_config(struct pcmcia_de
>      }
> =20
>      if ((link->conf.ConfigBase =3D=3D 0x03c0)
> -	&& (link->manf_id =3D=3D 0x149) && (link->card_id =3D 0xc1ab)) {
> +	&& (link->manf_id =3D=3D 0x149) && (link->card_id =3D=3D 0xc1ab)) {
>  	printk(KERN_INFO "pcnet_cs: this is an AX88190 card!\n");
>  	printk(KERN_INFO "pcnet_cs: use axnet_cs instead.\n");
>  	goto failed;
>=20


--=20
Cord Walter
email: cord.walter@gmx.de

Weil es niemanden etwas angeht, dass ich nichts zu verbergen habe:
http://www.gnupg.org/
http://www.truecrypt.org/
=2E..und =FCberhaupt: http://www.FreiheitstattAngst.de
