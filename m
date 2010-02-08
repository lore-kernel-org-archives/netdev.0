From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net tree
Date: Mon, 8 Feb 2010 13:22:43 +1100
Message-ID: <20100208132243.ab967d9c.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Mon__8_Feb_2010_13_22_43_+1100_KM_2hHKPG.=88CWW"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sridhar Samudrala <sri@us.ibm.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__8_Feb_2010_13_22_43_+1100_KM_2hHKPG.=88CWW
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

After merging the net tree, today's linux-next build (powerpc
ppc64_defconfig) failed like this:

net/packet/af_packet.c: In function 'packet_setsockopt':
net/packet/af_packet.c:1977: error: 'struct packet_sock' has no member name=
d 'rx_ring'
net/packet/af_packet.c:1977: error: 'struct packet_sock' has no member name=
d 'tx_ring'

Caused by commit bfd5f4a3d605e0f6054df0b59fe0907ff7e696d3 ("packet: Add
GSO/csum offload support").  This build has CONFIG_PACKET_MMAP unset.

I used the version of the net tree from next-20100205 for today.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Mon__8_Feb_2010_13_22_43_+1100_KM_2hHKPG.=88CWW
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAktvdXMACgkQjjKRsyhoI8wCjwCgklGTJHtFmHc0iZn41WGnsrpe
NXgAoLGRv9enkPNIdahJLf2mzz+RsxQz
=PhzF
-----END PGP SIGNATURE-----

--Signature=_Mon__8_Feb_2010_13_22_43_+1100_KM_2hHKPG.=88CWW--
