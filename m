From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: boot test failure (net tree)
Date: Wed, 17 Aug 2011 10:01:46 +1000
Message-ID: <20110817100146.3b557cf815a5a2ae09bc09a7@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__17_Aug_2011_10_01_46_+1000_DqzQb1=P662eBQRn"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__17_Aug_2011_10_01_46_+1000_DqzQb1=P662eBQRn
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

I do build and boot tests for various PowerPC servers I have access to.
Last night's test failed due to the fact that their ethernet drivers are
not longer being built.  In particular, CONFIG_TIGON3 newly depends on
CONFIG_NET_VENDOR_BROADCOM which will no be selected when doing a "make
oldconfig" from a working config.  Similarly for CONFIG_IBM_VETH and (the
new) CONFIG_VENDOR_IBM.  The original config had both CONFIG_TIGON3 and
CONFIG_IBM_VETH set (to y and m resp.) and the final config had neither.

These Kconfig changes need to be revised so that "make oldconfig" from a
working config builds the same set of drivers ...

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Wed__17_Aug_2011_10_01_46_+1000_DqzQb1=P662eBQRn
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJOSwTqAAoJEDMEi1NhKgbsYwgH/1JPwPg3Bgu/7suOANAjluWJ
FO7GCUZnON9YYgSAnorvkRYhbwG2UkiK7XV4du7pjjobI5KO2ZLRqygnSx0dAVKi
eqlRz5tSL+bfeiBGOX/+jF9oUenXbRjiv1KyO5FUNSRz9YOE9eBEqveRXuh9ypWy
oDfR7FAVr4fCc+0a3yLQBNyosq17E8i4zI8LhK4xUr9csnHh+ZZlooF2rzTPGRlK
6KoEA5r0ejxSwyRRvVm2p7of65Q2o5aHpNNOYf8U9qrk/YqKwFdGkWGY2JY8guwQ
DBCiLKANsid/K0MYhlxDMDsklHuEEkasuHBGdEqB3drTqeZwRR8EugyLoSZpCzQ=
=u8Vw
-----END PGP SIGNATURE-----

--Signature=_Wed__17_Aug_2011_10_01_46_+1000_DqzQb1=P662eBQRn--
