From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] let USB_USBNET always select MII
Date: Wed, 07 Nov 2007 00:10:45 -0800 (PST)
Message-ID: <20071107.001045.90391662.davem@davemloft.net>
References: <200711012024.57412.toralf.foerster@gmx.de>
	<20071101222524.GB7227@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: toralf.foerster@gmx.de, dbrownell@users.sourceforge.net,
	jgarzik@pobox.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46758
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756608AbXKGIKx convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 03:10:53 -0500
In-Reply-To: <20071101222524.GB7227@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Adrian Bunk <bunk@kernel.org>
Date: Thu, 1 Nov 2007 23:25:24 +0100

> All this USB_USBNET_MII trickery is simply not worth it considering h=
ow=20
> few code it saves.
>=20
> As a side effect, this also fixes the following compile error reporte=
d=20
> by Toralf F=F6rster:
>=20
> <--  snip  -->
>=20
> ...
>   LD      .tmp_vmlinux1
> drivers/built-in.o: In function `usbnet_set_settings':
> (.text+0xf1876): undefined reference to `mii_ethtool_sset'
> drivers/built-in.o: In function `usbnet_get_settings':
> (.text+0xf1836): undefined reference to `mii_ethtool_gset'
> drivers/built-in.o: In function `usbnet_get_link':
> (.text+0xf18d6): undefined reference to `mii_link_ok'
> drivers/built-in.o: In function `usbnet_nway_reset':
> (.text+0xf18f6): undefined reference to `mii_nway_restart'
> make: *** [.tmp_vmlinux1] Error 1
>=20
> <--  snip  -->
>=20
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

Applied, thanks Adrian.

