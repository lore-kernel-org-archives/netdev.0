From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build warning after merge of the net-next tree
Date: Wed, 21 Aug 2013 19:10:41 +1000
Message-ID: <20130821191041.712893827d8000c6dca8781b@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__21_Aug_2013_19_10_41_+1000_c3p1jnvZtg5x9nId"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	dingtianhong <dingtianhong@huawei.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__21_Aug_2013_19_10_41_+1000_c3p1jnvZtg5x9nId
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net-next tree, today's linux-next build (i386 defconfig
and probably others) produced this warning:

net/ipv6/addrconf.c: In function 'addrconf_notify':
net/ipv6/addrconf.c:2793:22: warning: 'link_dev' may be used uninitialized =
in this function [-Wuninitialized]
net/ipv6/addrconf.c:2802:21: note: 'link_dev' was declared here

Introduced by commit df8372ca747f ("ipv6: fix checkpatch errors in
net/ipv6/addrconf.c").  It looks like here are some missing braces.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Wed__21_Aug_2013_19_10_41_+1000_c3p1jnvZtg5x9nId
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJSFIQVAAoJEECxmPOUX5FETKYQAIErDSAQH+9sRRrWTIQ3+Xf/
Ly0wtF6nNI5S3GB7oW29NisHnRlppv++wumdwFXES2EdZppyx4c6N+0zOhVk7E3c
FXpMt5XsgPbanHmZAR/5LwSPl5CGmHBUFig5H70pBFWKJZll+AzZXMC+Dm5gOAyO
LxG5vvepPiNe5/HBdGBip+mva1enx7Y4Kzvp746LoAbCMEtGoi4HIe6/Ud8MngWN
EZTFetd0o47eylTk/QKakDRPDWxBsNr3Z8DhqjAkwkekJRYxTy/5koy5EX2qq17u
cV80RdqIKErzQ3bZ4HEj6V2PHnWB1JRs4ghEnfwHtmihESlYvNkJFerr0KiN2+hb
gXe0PxhtjqKN3wlCU2KlehwFtHAhdIoT52YND8/pExiSekKmCSJSXfBBTPymBAUy
mCFmVr4Cpl4X2L+rPCplbgJO1BTh72GoTuP64bH+9siT/mHq6ucbiztU5Fy5zpzs
cGbFJfjRDJrgCG+N70c5e2h4g8GlHcc9MiwZFfWoegCKA10rpReEZfJmnuPNQ2bP
FbKM7LUR6xJA2PKG+tlt/0x6HjKJy4R0+wzwQ2bu3o2bI59Crz4icULUD98fUB3A
JPyq+akGy42eAH4d2EvyACLCFoMt0pXFKFIjobmS1RctoOkBwlsnfyRu5gaW8EwD
nv1wvHzdP9nZzeu7TUxR
=9D5A
-----END PGP SIGNATURE-----

--Signature=_Wed__21_Aug_2013_19_10_41_+1000_c3p1jnvZtg5x9nId--
