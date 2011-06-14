From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Wed, 15 Jun 2011 08:56:17 +1000
Message-ID: <20110615085617.949d418f.sfr@canb.auug.org.au>
References: <20110609145657.96fae0d0.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__15_Jun_2011_08_56_17_+1000_/1ovAeAwvHKn8Vb9"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Greg KH <greg@kroah.com>, Alexey Dobriyan <adobriyan@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110609145657.96fae0d0.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__15_Jun_2011_08_56_17_+1000_/1ovAeAwvHKn8Vb9
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Thu, 9 Jun 2011 14:56:57 +1000 Stephen Rothwell <sfr@canb.auug.org.au> w=
rote:
>
> After merging the net tree, today's linux-next build (x86_64 allmodconfig)
> failed like this:
>=20
> [See summary in patch below.]
>=20
> [Hmmm, suddenly allmodconfig is building stuff in staging?  Ah ha!
> Commit fe35a59e16fb ("Staging: remove STAGING_EXCLUDE_BUILD
> option")  Greg, a bit of warning might have been nice :-( ]
>=20
> I assume that this is fallout from commit a6b7a407865a ("net: remove
> interrupt.h inclusion from netdevice.h").
>=20
> I added the following patch for today:
>=20
> From 520e46c255afa851b33e5c4a2bcf2112ecccbb6f Mon Sep 17 00:00:00 2001
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Thu, 9 Jun 2011 14:19:09 +1000
> Subject: [PATCH] net/staging: add needed interrupt.h and hardirq.h includ=
es

I am still getting these build errors and applying the patch.  I would
assume that if you merge Linus' tree (-rc3 will do it) into net-next, you
will get these failures as well (for an x86_64 allmodconfig build at
least).

I think that this patch would probably apply to just the net-next tree
anyway.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Wed__15_Jun_2011_08_56_17_+1000_/1ovAeAwvHKn8Vb9
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJN9+cRAAoJEDMEi1NhKgbsQ3EH/0rhax959/IdekarHqQ+tpPz
P/56fGNnq+LrpHUR1JbQ57yPs0Hr2cbjcrKUYQSC50Y5bNwAtJ/DdYbdCAME400q
X1cVKm24c4AY1HlbD5vYxDXbNRinQbjWn+Chqe4RiVG54paQSaQz4zQ/Md5qjjOg
PbuK8hQCwvSh2+Z8EO9kVHNxQUznFjbxHsAluOEx0xaxMMPE0sKC/hFMINqOiewl
RsfN4IRqYZXJh+dZUPqlfF8LP2n7yqrUg+z43TwKRi1YvZUf/T0Uy1+J7PDyLa3p
FshQC+bGCfpjaTd9+eqhIYS6kxJgOF7xO/8J/q5CfXdqVO6zJFQiA/KGmNgYmeI=
=TSJf
-----END PGP SIGNATURE-----

--Signature=_Wed__15_Jun_2011_08_56_17_+1000_/1ovAeAwvHKn8Vb9--
