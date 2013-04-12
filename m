From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree (net-next
 tree related)
Date: Fri, 12 Apr 2013 16:00:18 +1000
Message-ID: <20130412160018.3d54c801f40fbc13058ded07@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__12_Apr_2013_16_00_18_+1000_i.wgQ1IU4MA4oC/c"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	stephen hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__12_Apr_2013_16_00_18_+1000_i.wgQ1IU4MA4oC/c
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the final tree, today's linux-next build (powerpc
allyesconfig) failed like this:

net/core/netprio_cgroup.c:250:29: error: static declaration of 'net_prio_su=
bsys' follows non-static declaration
include/linux/cgroup_subsys.h:71:1: note: previous declaration of 'net_prio=
_subsys' was here

Caused by commit 763eff57de89 ("netprio_cgroup: make local table static")
from the net-next tree.

I have reverted that commit for today.

/me hates macros that construct symbols ...

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Fri__12_Apr_2013_16_00_18_+1000_i.wgQ1IU4MA4oC/c
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRZ6LyAAoJEECxmPOUX5FE9k0QAIZZHB3XPG16jLsOROlzd98S
rrUgt/yd6nLHJ4TihuAPni6SIKkWNwSgawuXBosPicLuhcDfI5hGIH2a3KfT7Gli
34RsAWvTL1ZYjsu6RKIWZlQGbm9CD0K35RJ+V6UQot0awTyJ+AXQ/3O1tBe6q4T1
UqdSNaZpXDaMLZXm60iNWpGZbCd0c6IAdnRQw5rSI1HbPefPwHXpervEhJiZG06e
5swt6zgZahO29Ii5yl140/xoG8R7Av/5JQT01wKpnEHWkfR1DH4D3Vfji1s7Jbsf
guI7a91MrgfCiF+yN73oQA3fSbyDW8azU6SjGgnf/onHVmbWoj57NYpyiq1dziJJ
m7pNhM/wsgXkg5J54jYumr8hKxYwUa7GbrHIcwHU525jCQfl+NfRhv6FuIzhcjFV
rYVBuC7dYyf8vciguGksyLrpdwg8h5ds3etX9CzZFwr1Z28grFVuvSZuA49DA15Q
L+XPv2RwkCnNK0urLuWFDq+X968cFTmcrD9skRUQW+aoE5pIkkkbAc67sUg7yE32
CjDmsgNtRbpRMgimuIyujQObTFrFKwhmiAopOflZ1lUZa1YG43LiNZ1RB8uQ1Jmv
zJvgOMhITXcM+ookYc9/LTlJvj/bYA6PcHALWOddh4kwv9dKmt57pxtCPuYO5hx3
MsI/XUkrcd85zdYtgkeK
=AESV
-----END PGP SIGNATURE-----

--Signature=_Fri__12_Apr_2013_16_00_18_+1000_i.wgQ1IU4MA4oC/c--
