From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [B.A.T.M.A.N.] [PATCH 01/10] batman-adv: fix soft-interface MTU
 computation
Date: Tue, 18 Feb 2014 07:44:53 +0100
Message-ID: <53030165.2050404@meshcoding.com>
References: <1392670129-2498-1-git-send-email-antonio@meshcoding.com> <1392670129-2498-2-git-send-email-antonio@meshcoding.com> <20140217.161314.741869447870850076.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="lwUKLMUudfQxo5RbpvCitHEBpt16U01JW"
Cc: netdev@vger.kernel.org, mareklindner@neomailbox.ch
To: The list for a Better Approach To Mobile Ad-hoc
	 Networking <b.a.t.m.a.n@lists.open-mesh.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:20663 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751006AbaBRGqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 01:46:36 -0500
In-Reply-To: <20140217.161314.741869447870850076.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--lwUKLMUudfQxo5RbpvCitHEBpt16U01JW
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 17/02/14 22:13, David Miller wrote:
> From: Antonio Quartulli <antonio@meshcoding.com>
> Date: Mon, 17 Feb 2014 21:48:40 +0100
>=20
>> +	atomic_set(&bat_priv->packet_size_max, min_mtu);
>=20
> Please fix this.
>=20
> The only operations performed on packet_size_max are 'set' and
> 'read'.  This is not what one uses atomic_t's for.
>=20
> The use of an atomic_t in this context is a NOP.  You aren't
> getting any kind of synchronization at all.

True. Thanks for the suggestion.
Unfortunately this is not the only "fake-atomic" variable we have.

We'll send a change for this later within our pull request for net-next, =
ok?


--=20
Antonio Quartulli


--lwUKLMUudfQxo5RbpvCitHEBpt16U01JW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTAwFyAAoJEEKTMo6mOh1VZpUP/Amp8NL6jJnQFsJG5UrqvLoa
NHupYrSV4pokOfDg6LPfLpVYXPNSy0kQFqUsP6lLyrmSTnhuMIWYYFL31+dm4A0Z
e5WDX+WhmbbGc+LCGygPmftUA8uEyIritcpVd7QBc+botqMR6CN5og35hMYrd9Cb
OX+IDFusxJfDbprpfmlyYv/l+D5kHZ/Wyuk929XaAy1uR4fm5loBgcprKQGtLVPy
1ipBkOZvZEJw54iy24oX+qKqqP5+7s0JCR9FaxyTEXDk5yND+8MAHXkhoVY2AhDD
hXrOdrefbw55UYnNRYjRaN3vGSLNwZmr8sTg+MRJ5YvAQorPEknGUWLPD8udmK5b
frSiGYhtL39IUUexwDIH1GDT1I0h8HutSDXDoicEi0vmUQj+GXnIO7GPZNe3gZzH
97xgpSAzGdx4Q85G3PIlAfXqm91vJrQQ4hF8DQSqExgGxIMcsftBRgXeEOe69N9c
dT4on7RS6MO6LLbMnxmIlPhN/RoVQjvc3lLxJx15A9fZXZEh7r74ahAoF+lS68o9
B8o10JS3EB9fvwHtP3Se+1RblC1AcdBmc5efB2B5iQSZjCMcMzhz+VqNeqV0uMlF
3U4QodFQty2W6/pPfvAf//3Dhfc1bqZe7Y10VobPdxahNUwynBgA7E+cSM45Wfpg
B1iZBXVOim2VrIVxzNnJ
=lcZh
-----END PGP SIGNATURE-----

--lwUKLMUudfQxo5RbpvCitHEBpt16U01JW--
