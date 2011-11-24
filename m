From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the arm-soc tree with Linus' tree
Date: Thu, 24 Nov 2011 11:58:05 +1100
Message-ID: <20111124115805.d2b5cdc699b9d6ed300b9c09@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__24_Nov_2011_11_58_05_+1100_YyYFfRPsU6PwYaon"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Jean-Christophe PLAGNIOL-VILLARD" <plagnioj@jcrosoft.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Jamie Iles <jamie.iles@mathembedded.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__24_Nov_2011_11_58_05_+1100_YyYFfRPsU6PwYaon
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Arnd,

Today's linux-next merge of the arm-soc tree got a conflict in
drivers/net/ethernet/cadence/Kconfig between commit eccab1ec87d0
("net/cadence: enable by default NET_ATMEL") from Linus' tree and commit
f75ba50bdc2b ("macb: initial support for Cadence GEM") from the arm-soc
tree.

I fixed it up (see below) and can carry the fix as necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/ethernet/cadence/Kconfig
index b48378a,a2e1500..0000000
--- a/drivers/net/ethernet/cadence/Kconfig
+++ b/drivers/net/ethernet/cadence/Kconfig
@@@ -5,9 -5,8 +5,9 @@@
  config HAVE_NET_MACB
  	bool
 =20
- config NET_ATMEL
- 	bool "Atmel devices"
+ config NET_CADENCE
+ 	bool "Cadence devices"
 +	default y
  	depends on HAVE_NET_MACB || (ARM && ARCH_AT91RM9200)
  	---help---
  	  If you have a network (Ethernet) card belonging to this class, say Y.

--Signature=_Thu__24_Nov_2011_11_58_05_+1100_YyYFfRPsU6PwYaon
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJOzZadAAoJEECxmPOUX5FEk3EP/RY6aPXwAihPWoblHNaVrWYS
T0imAN0Ntl/xYavK1XVpt2/1zj4rztJM825uKHYBy5NOZuIBR2wS15Jjm4Hs27aB
3g4ml9sJfgr+eUWMmyM92S+MLopc6CEMb5P/aYy+UpeY7smGRJ6g7A8s7AsIDW2s
am9qK99aura6lxI4HPIyJTX8kWpNmGoF333esO4/4M9S7grPJ7SMB8GpqRSGgvDG
NjkcGngm5aLxqeCN/RwaTZ7OZjBqtauslCqGsIYEZdXHqMH+QuQ0Q38S1T7W8ogG
xJA+Wj+ggU7zzIe98f3NeSjcq76I6AGj17ElNWPlkaWpxNZ24bvuGabp82y4rLTd
KcFRLLw4Zt0oH6XGx8fTi3iSwKlVRtgrs3q43RxAY7RW3EFjMhxK0NXvN9PoNDR0
IWT/asQk27oO7oUlJx0PWCgyzmvWWhESYJ3VFbIBo7ND79a/sgSyulhVsDJQDuBt
sHggyS7BwrGNDcsnCueX8VPIZnTfkuIcX/XAR+x1HAxxyvBx7FdBbmcUas2Emw1x
awHe5L6gR5TbnCMfI4fP/Czyb8Zy8kzFVqp7FmPiHGzivx2xCZlSwqiGRzJ1cTHh
JfFhUQK8lZyR5StqVmwvI+xKaO4PMl8FMMD8SUBzXqfWD/Y5YIGcVIFsC7XZd+JW
neFqWdUPh3HXsQVc8UM/
=72m5
-----END PGP SIGNATURE-----

--Signature=_Thu__24_Nov_2011_11_58_05_+1100_YyYFfRPsU6PwYaon--
