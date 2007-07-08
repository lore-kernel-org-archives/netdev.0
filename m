From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] CXGB3: Replace kcalloc(1,...) with kmalloc() in
	cxgb3_offload.c.
Date: Sun, 08 Jul 2007 12:08:49 +0200
Message-ID: <1183889330.3771.0.camel@johannes.berg>
References: <Pine.LNX.4.64.0707080537360.7944@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-bLZQdLJtPjxtwG/7k3OU"
Cc: netdev@vger.kernel.org
To: "Robert P. J. Day" <rpjday@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:38384 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755691AbXGHKJF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jul 2007 06:09:05 -0400
In-Reply-To: <Pine.LNX.4.64.0707080537360.7944@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-bLZQdLJtPjxtwG/7k3OU
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2007-07-08 at 05:39 -0400, Robert P. J. Day wrote:

> -	t =3D kcalloc(1, sizeof(*t), GFP_KERNEL);
> +	t =3D kcalloc(sizeof(*t), GFP_KERNEL);
               ^
I don't think that's going to work, and shouldn't it probably use
kzalloc instead of kmalloc (as you wrote in subject)

johannes

--=-bLZQdLJtPjxtwG/7k3OU
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGkLex/ETPhpq3jKURAlCVAJ4iIXVy1Q3MpAoZU38cD3jnz2jDLQCfbtwd
jRDPXGulJP2Gr4k5Qmhhecg=
=tYGw
-----END PGP SIGNATURE-----

--=-bLZQdLJtPjxtwG/7k3OU--

