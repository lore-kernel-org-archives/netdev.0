From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree (net tree
 related)
Date: Thu, 18 Mar 2010 15:23:51 +1100
Message-ID: <20100318152351.df9e11a3.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Thu__18_Mar_2010_15_23_51_+1100_nmirc.aVGp6rZyRq"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__18_Mar_2010_15_23_51_+1100_nmirc.aVGp6rZyRq
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

After merging the final tree, today's linux-next build (powerpc
ppc44x_defconfig) failed like this:

net/core/dev.c: In function 'net_rps_action':
net/core/dev.c:3183: error: implicit declaration of function '__smp_call_fu=
nction_single'

Caused by commit 0a9627f2649a02bea165cfd529d7bcb625c2fcad ("rps: Receive
Packet Steering") from the net tree.   This config does not have
CONFIG_SMP set.  __smp_call_function_single is only available when
CONFIG_SMP is set.

I have reverted that commit for today.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__18_Mar_2010_15_23_51_+1100_nmirc.aVGp6rZyRq
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkuhqtcACgkQjjKRsyhoI8wNuACfZ+5wMQY1DNF+VrcI+LsBPOp4
10MAn3DzBVoFzF/xJmS2unuvdyUE5kM3
=KEtx
-----END PGP SIGNATURE-----

--Signature=_Thu__18_Mar_2010_15_23_51_+1100_nmirc.aVGp6rZyRq--
