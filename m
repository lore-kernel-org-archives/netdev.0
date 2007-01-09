From: Jan Kiszka <jan.kiszka@web.de>
Subject: Re: [PATCH] d80211: don't symlink empty default keys
Date: Tue, 09 Jan 2007 23:43:58 +0100
Message-ID: <45A41AAE.4040606@web.de>
References: <45A4183E.4010401@web.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig80192F3163EDF5BD9A08F181"
Cc: netdev@vger.kernel.org, Ivo Van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate01.web.de ([217.72.192.221]:48055 "EHLO
	fmmailgate01.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932483AbXAIWoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jan 2007 17:44:04 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <45A4183E.4010401@web.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig80192F3163EDF5BD9A08F181
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Jan Kiszka wrote:
> This gets rid of annoying
>=20
> wlan0: cannot create symlink to default key
>=20
> in my syslog with latest rt2x00. The patch takes care that in case of
> (key/old_key =3D=3D NULL && set_tx_key) the existing default key symlin=
k is
> removed correctly. Moreover, it tests for key!=3DNULL before trying to =
register
> a new default link.
>=20

Grr, just noticed that the subject was still only reflecting one part of
the patch. Let's call it "fix default key symlink creation/cleanup".

Jan


--------------enig80192F3163EDF5BD9A08F181
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iD8DBQFFpBquniDOoMHTA+kRAhnhAJ0XFK+ejV6qxtw9m6a17kYInbgE5wCfUI/W
041XkLtKEs/foC0Sv+vO5H0=
=3PY0
-----END PGP SIGNATURE-----

--------------enig80192F3163EDF5BD9A08F181--
