From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: net tree build warning
Date: Fri, 22 May 2009 15:16:42 +1000
Message-ID: <20090522151642.e79e22ee.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__22_May_2009_15_16_42_+1000_TjI_tiSbL0ylo9_I"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__22_May_2009_15_16_42_+1000_TjI_tiSbL0ylo9_I
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

Today's linux-next build (powerpc ppc64_defconfig) produced this warning:

net/core/netpoll.c: In function 'poll_one_napi':
net/core/netpoll.c:141: warning: passing argument 1 of 'trace_napi_poll' fr=
om incompatible pointer type
include/trace/napi.h:7: note: expected 'struct napi_struct *' but argument =
is of type 'struct net_device *'

Introduced by commit 4ea7e38696c7e798c47ebbecadfd392f23f814f9 ("dropmon:
add ability to detect when hardware dropsrxpackets").
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__22_May_2009_15_16_42_+1000_TjI_tiSbL0ylo9_I
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkoWNToACgkQjjKRsyhoI8yrbwCeNfjaxPytRnyC94uRiaXqXj1+
wyoAoJ8nQirfAhVzvpAsLUeb+sjnr5wB
=dtnZ
-----END PGP SIGNATURE-----

--Signature=_Fri__22_May_2009_15_16_42_+1000_TjI_tiSbL0ylo9_I--
