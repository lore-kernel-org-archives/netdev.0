From: Carlos =?utf-8?Q?Mart=C3=ADnn?= Nieto <carlos@cmartin.tk>
Subject: Re: tiacx module fail
Date: Mon, 11 Sep 2006 14:25:41 +0200
Message-ID: <20060911122541.GA4537@kiopa.cmartin.tk>
References: <4503F640.3040300@fastwebnet.it>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ew6BAiZeqk4r7MaW"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82.red-82-159-197.user.auna.net ([82.159.197.82]:10396 "EHLO
	indy.cmartin.tk") by vger.kernel.org with ESMTP id S1751433AbWIKMZw
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Sep 2006 08:25:52 -0400
To: VinX <vincenx@fastwebnet.it>
Content-Disposition: inline
In-Reply-To: <4503F640.3040300@fastwebnet.it>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--ew6BAiZeqk4r7MaW
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Sep 10, 2006 at 01:25:52PM +0200, VinX wrote:
> Hi,
> i have a little problem with dlink dwl650+ pcmcia.
> After I downloaded wireless-2.6.git with cogito, compiled, rebooted my
> laptop and loaded the acx_pci module. But my pcmcia don't work.
> If i give this command line:
> # iwlist scanning
> eth1     Interface doesn't support scanning : Resource temporarily
> unavailable
> I tried with a 2.6.18-rc5 with tiacx and 2.6.17.13 with acx module, same
> result.
> The dmesg with tiacx module is:
<snip>
> acx: form factor 0x01 ((mini-)PCI / CardBus), radio type 0x0D (Maxim),
> EEPROM version 0x05, uploaded firmware 'Rev 1.9.10.0_A4' (0x01030505)
> creating /proc entry driver/acx_wlan0
> creating /proc entry driver/acx_wlan0_diag
> creating /proc entry driver/acx_wlan0_eeprom
> creating /proc entry driver/acx_wlan0_phy
> acx v0.3.35: net device wlan0, driver compiled against wireless
> extensions 20
<snip>
> ---
>=20
> Any idea?
> Sorry for my bad english and for this long mail!

 The error message says it is trying to scan with eth1, but the driver
log says the card is on wlan0.

 Try doing `iwlist wlan0 scan`. That should work.

   cmn
--=20
Carlos Mart=C3=ADn Nieto    |   http://www.cmartin.tk
Hobbyist programmer    |
--ew6BAiZeqk4r7MaW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQFFBVXFEVXxXOiy6a4RAu5wAJ0fj80+se2rfl8vOp0Z7QTbnc5UmwCfYrIy
RWZvtwseIkjEeHSWHqXQUIE=
=5kkV
-----END PGP SIGNATURE-----

--ew6BAiZeqk4r7MaW--
