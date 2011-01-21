From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net tree
Date: Fri, 21 Jan 2011 12:05:53 +1100
Message-ID: <20110121120553.5e827247.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__21_Jan_2011_12_05_53_+1100_ysU56cGI9R2wgHcS"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__21_Jan_2011_12_05_53_+1100_ysU56cGI9R2wgHcS
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net tree, today's linux-next build (powerpc
ppc64_defconfig) failed like this:

ERROR: ".nf_conntrack_tstamp_fini" [net/netfilter/nf_conntrack.ko] undefine=
d!
ERROR: ".nf_conntrack_tstamp_init" [net/netfilter/nf_conntrack.ko] undefine=
d!

Presumably caused by commit a992ca2a0498edd22a88ac8c41570f536de29c9e
("netfilter: nf_conntrack_tstamp: add flow-based timestamp extension").

I have used the net tree from next-20110120 for today.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__21_Jan_2011_12_05_53_+1100_ysU56cGI9R2wgHcS
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNONvxAAoJEDMEi1NhKgbsJDQH/2xA740qnDIrQBSq/p2Hv6L6
nQqsdshwW5hgBaD1EnGc6h4QMdvajeJiyw+ix5X12V8rFGz2mdJXfP8XjQlKWhMa
MT+fkyh2YCt3jzj7wBjtvm5pIrgysDNYj3wkPkR70MQ/oSfM7eYRHkCLVn6VYxv/
lKuP1ll90UTHfI30XSRRJfg2JzOcdsIuMuKWtmJYBi/C1rGIIB99lwjACQPEwQcB
rMzYsSxDEoWoPFPkl2gXEw7uOGnL8LsLpbThplNZAz0/I3eLHLtHYWJL/RenBw2I
xfBKmr58Xo5Al4wPsaokB8gd6Qzf1sn1Ztd+XaHwh3QIpfjyhb1AD9Eu+l54W/k=
=W1NI
-----END PGP SIGNATURE-----

--Signature=_Fri__21_Jan_2011_12_05_53_+1100_ysU56cGI9R2wgHcS--
