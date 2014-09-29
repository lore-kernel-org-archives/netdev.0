From: Michael Grzeschik <mgr@pengutronix.de>
Subject: Re: [PATCH 0/5] ARCNET: add support for EAE multi interfac card
Date: Mon, 29 Sep 2014 11:07:21 +0200
Message-ID: <20140929090721.GE18174@pengutronix.de>
References: <1411566113-15583-1-git-send-email-m.grzeschik@pengutronix.de>
 <20140928.164421.1247481867383564525.davem@davemloft.net>
 <20140928.170150.1279138730834841306.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: m.grzeschik@pengutronix.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel@pengutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:34701 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751439AbaI2JHY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 05:07:24 -0400
Content-Disposition: inline
In-Reply-To: <20140928.170150.1279138730834841306.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 28, 2014 at 05:01:50PM -0400, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Sun, 28 Sep 2014 16:44:21 -0400 (EDT)
>=20
> > From: Michael Grzeschik <m.grzeschik@pengutronix.de>
> > Date: Wed, 24 Sep 2014 15:41:48 +0200
> >=20
> >> this series adds support for the PLX Bridge based multi interface
> >> pci cards and adds support to change device address on com200xx ch=
ips
> >> during runtime.
> >>=20
> >> This series is based on v3.17-rc6.
> >=20
> > Series applied to net-next, thanks.
>=20
> I had to revert, this breaks the build:
>=20
> drivers/net/arcnet/com20020_cs.c:115:8: error: redefinition of =E2=80=
=98struct com20020_dev=E2=80=99
>  struct com20020_dev {
>         ^
> In file included from drivers/net/arcnet/com20020_cs.c:43:0:
> include/linux/com20020.h:66:8: note: originally defined here
>  struct com20020_dev {
>         ^
> make[3]: *** [drivers/net/arcnet/com20020_cs.o] Error 1
> make[2]: *** [drivers/net/arcnet] Error 2
> make[2]: *** Waiting for unfinished jobs....
> make[1]: *** [drivers/net] Error 2
> make[1]: *** Waiting for unfinished jobs....
> make: *** [drivers] Error 2

Oh, I didn't look into the other com20020 drivers.
I will fix it and send v2.

Thanks,
Michael

--=20
Pengutronix e.K.                           |                           =
  |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0  =
  |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-555=
5 |
