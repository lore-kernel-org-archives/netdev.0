From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Tue, 19 Feb 2013 12:17:22 +1100
Message-ID: <20130219121722.c5470cdd2040712deb8e8043@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__19_Feb_2013_12_17_22_+1100_+gZotxKmjDXBTSyV"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	=?UTF-8?B?IllPU0hJRlVKSSBIaWRlYWtpIC8g5ZCJ6Jek6Iux5piOIg==?=
	<yoshfuji@linux-ipv6.org>, Romain KUNTZ <r.kuntz@ipflavors.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__19_Feb_2013_12_17_22_+1100_+gZotxKmjDXBTSyV
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net-next tree, today's linux-next build (x86_64
allmodconfig) failed like this:

net/ipv6/xfrm6_policy.c: In function 'xfrm6_dst_destroy':
net/ipv6/xfrm6_policy.c:238:6: error: 'struct rt6_info' has no member named=
 'n'
net/ipv6/xfrm6_policy.c:239:28: error: 'struct rt6_info' has no member name=
d 'n'

Caused by commit 887c95cc1da5 ("ipv6: Complete neighbour entry removal
from dst_entry") interacting with commit 18cf0d0784b4 ("xfrm: release
neighbor upon dst destruction") from the net tree.

I assume that the problem fixed by the net tree commit is fixed some
other way in the net-next tree, so I reverted the net tree commit.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Tue__19_Feb_2013_12_17_22_+1100_+gZotxKmjDXBTSyV
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRItKiAAoJEECxmPOUX5FESKMP/2ksOFDukLS5ael3qlt64MFW
+Rnv2X4REVJte2ylwqk4wbH7fsb1EMQfOADZeJJBKZgZgHMM+9yPar/iWLJBqMr6
pLrZyUWvlelRrFroky7C3urzEy/eNBbBMM95oFfoe8/jJF/twOFWRRoFalhdOPbs
a4f8GnbDfNc4q65josVHmV8UPJmWfNs18Cd2G5VPeok3CbCmSvvkNlQf/55EeXOf
08+1ijnRSKu6AR0aBPA3NcZpZjuqNVhv6p65QF1SFgZIyDfUT0k5tRdYSPAA8q8o
CNT1C5uF/0Xc2Vv2g8GXmpeksL1CVwmvHg6A6Ero7govY0eKdOU8n56R99AdG5Ex
tMpdUaVCS0W0FaMDTevKBe9P0vJgDK90HIYQe+pP8/cODmMdxFXAh3gyvwxMOR30
7JfeBrL5fp1+D047Ffl9e+IO8DV0Mc7hhxxQYfVAvDh8BepnfS7GG2Op5uCMcXlh
9DW73gnG52UzmHzpEOo7iP2CimRQJHYLV5szxUsF2NsUt5SHGzRamXSEfvcA7DnA
J6Oto6EmKATy1tyU0H55zl3gou0LIfzesTFL4VHa7sARRysab6ecLsCr1nbCOano
iXeyMKe1Rn3fdpeCEe5sb+LsAInIWWbjWaDEhUXkGrS1U6VxzUzO38JZ/mlJtI3T
nlwBH+tMsoNAIb3ManF4
=+pLC
-----END PGP SIGNATURE-----

--Signature=_Tue__19_Feb_2013_12_17_22_+1100_+gZotxKmjDXBTSyV--
