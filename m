From: Malte =?UTF-8?B?U2NocsO2ZGVy?= <maltesch@gmx.de>
Subject: Re: 2.6.24 regression: reference count leak in PPPoE
Date: Sun, 20 Jan 2008 21:16:19 +0100
Message-ID: <20080120211619.11535a95@highlander.home.lan>
References: <200801202053.30386.ak@suse.de>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="Sig_/g6_XeXJ.s1ma5V6oZSrcPja";
 protocol="application/pgp-signature"; micalg=PGP-SHA1
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andi Kleen <ak@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756296AbYATUQj@vger.kernel.org>
In-Reply-To: <200801202053.30386.ak@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/g6_XeXJ.s1ma5V6oZSrcPja
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Sun, 20 Jan 2008 20:53:30 +0100
Andi Kleen <ak@suse.de> wrote:

>=20
> My workstation running 2.6.24-rc8 just hung during shutdown with an endle=
ss=20
> (or rather I didn't wait more than a few minutes) loop of=20
>=20
> unregister_netdev: waiting for ppp-device to become free. Usage count =3D=
 1
>=20
> ppp-device was an active PPPoE device.
>=20
> No more information currently.

Now that you mention it, this happened to me too this morning. My
system stops the ppp interface (pppoe) and starts it again (my provider
shuts down the link every 24 hours, I want that to happen during the
night, so I do a ifdown ppp0).




--=20
---------------------------------------
Malte Schr=C3=B6der
MalteSch@gmx.de
ICQ# 68121508
---------------------------------------


--Sig_/g6_XeXJ.s1ma5V6oZSrcPja
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFHk6wW4q3E2oMjYtURAibFAJ9nbk8VJfK626vw3LuH/J3SxiBqGACgqkDt
XC9CmrOpuhZhSwRlobcfs+U=
=Ngof
-----END PGP SIGNATURE-----

--Sig_/g6_XeXJ.s1ma5V6oZSrcPja--
