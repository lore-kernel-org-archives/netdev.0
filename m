From: Markus Pargmann <mpa@pengutronix.de>
Subject: Re: [PATCH v2] can: c_can: add xceiver enable/disable support
Date: Wed, 20 Jan 2016 15:29:14 +0100
Message-ID: <1712225.zGdy6Arcqk@adelgunde>
References: <1453297443-23279-1-git-send-email-m.grzeschik@pengutronix.de> <20160120141151.GA626@airbook.eia.lan>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart2497567.P4FrxcL9uA"; micalg="pgp-sha256"; protocol="application/pgp-signature"
Cc: Kurt Van Dijck <dev.kurt@vandijck-laurijssen.be>,
	Michael Grzeschik <m.grzeschik@pengutronix.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-can@vger.kernel.org, mkl@pengutronix.de, wg@grandegger.com
To: kernel@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:37610 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932721AbcATO3Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 09:29:24 -0500
In-Reply-To: <20160120141151.GA626@airbook.eia.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--nextPart2497567.P4FrxcL9uA
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="us-ascii"

Hi,

On Wednesday 20 January 2016 15:11:51 Kurt Van Dijck wrote:
>=20
> > diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/=
c_can.c
> > index f91b094..0723aeb 100644
> > --- a/drivers/net/can/c_can/c_can.c
> > +++ b/drivers/net/can/c_can/c_can.c
> > @@ -1263,6 +1271,10 @@ int register_c_can_dev(struct net_device *de=
v)
> >  =09 */
> >  =09pinctrl_pm_select_sleep_state(dev->dev.parent);
> > =20
> > +=09priv->reg_xceiver =3D devm_regulator_get(priv->device, "xceiver=
");
>=20
> I assume "xceiver" is the shorter name for "transceiver"?
> In that case, I suggest changing the devicetree label to "transceiver=
".
> It would become a mess if different drivers use different names.
> I see no real benefit for naming it "xceiver". "trx" is even shorter =
:-)
> See also http://www.acronymfinder.com/TRX.html
>=20
> The internals, like variable names, do not really matter here.
>=20
> I haven't looked at other driver, yet the argument still stands.

Oh right and perhaps it is necessary to add some documentation for the
devicetree binding if it is not generic already? In that case the DT
mailing list is missing as well.

Best Regards,

Markus

=2D-=20
Pengutronix e.K.                           |                           =
  |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0  =
  |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-555=
5 |

--nextPart2497567.P4FrxcL9uA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCAAGBQJWn5m6AAoJEEpcgKtcEGQQliwP/0M/6fToxbFP2KVBLMJVGvo4
taY3lizR4lS8vXrYKb7DhO4J8gjPVSw+QZHHYGufNrUgJnfSKrqEz9NRh+IsXI4Y
S+NfjSP6ZungxWwpyzLWDhcal6pUuwsGauTMNF0wVqOh6gHLRHWJinISfY483YMd
sIIfffqxLlF81IU7+hdsJr0p4tLlFKH/nrmABvD8qryG5+fglvfJCqhgrFzxpWfW
f7RMwUAWGrOu6Y3rZL2k19MGS24LUrmJ4+jM2GBZ/J75f5x30jYn5jsMhZcLOjfD
V+Hgt7UeyAPE3xi4YsAMkP8ku5ExhFcj17eVL1GeY0TeBJjNTHvfaLqU107EtEUW
XOZgif4BDrFa78KkqB2nIUOSw6URH16Oa/SlZIvm3Bij004KM80ymdudW54s5zo4
0CUPBcrPEI8/KyKPHInB4J9roydKj8wxAXw2ClMTlyT3EjJVY+/pLjeEFVmV7OKk
2c8dAHEa5jTRuu0TM/rOLPMAYMVcVxSns2OOf25W3Y2tqxhUstULt/mCOaqjZIOz
qcIU/r02SBezMOI04nBTsMNNzUIA40/Q9vIl6FgxMZDOQrdNlTnQwABfKYaQyVs7
KzvkDg/7LOgUBVF5dqCyrmVPTTFbzkorT8L7fEYQa0uXil3+ym9VgjHf0TAzYs6c
V2AFKRBaVyG3x6u6+OKN
=klEO
-----END PGP SIGNATURE-----

--nextPart2497567.P4FrxcL9uA--
