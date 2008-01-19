From: Andrey Rahmatullin <wrar@altlinux.ru>
Subject: Re: [PATCH][NEIGH] Fix race between neigh_parms_release and
	neightbl_fill_parms
Date: Sat, 19 Jan 2008 19:15:41 +0500
Message-ID: <20080119141541.GA12259@wrars-comp.wrarsdomain>
References: <4785F9F5.6070502@openvz.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="5mCyUwZo2JvN/JJP"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from k66.ru ([87.224.128.21]:57517 "EHLO k66.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751800AbYASOss (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Jan 2008 09:48:48 -0500
Received: from [87.224.251.61] (HELO wrars-comp.wrarsdomain)
  by k66.ru (CommuniGate Pro SMTP 5.1.13)
  with ESMTP id 108941244 for netdev@vger.kernel.org; Sat, 19 Jan 2008 19:18:43 +0500
Content-Disposition: inline
In-Reply-To: <4785F9F5.6070502@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--5mCyUwZo2JvN/JJP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

This patch causes messages like 'unregister_netdevice: waiting for ppp0 to
become free. Usage count =3D 1' when I try 'ifdown ppp0'. This happens in a=
ll
kernel versions containing this commit and doesn't happen in 2.6.24-rc8
with this commit reverted.

--=20
WBR, wRAR (ALT Linux Team)

--5mCyUwZo2JvN/JJP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.8 (GNU/Linux)

iEYEARECAAYFAkeSBgcACgkQB4Vf7hFmt5XTPgCfXbGHr0QypVUKqyrFuHEi8eo+
ex0AniA4lfHMtckJgbApveUTzIIi20Hh
=D4SE
-----END PGP SIGNATURE-----

--5mCyUwZo2JvN/JJP--
