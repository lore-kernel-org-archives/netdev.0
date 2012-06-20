From: Valdis Kletnieks <valdis.kletnieks@vt.edu>
Subject: next-20120620 build error in netfilter
Date: Wed, 20 Jun 2012 13:14:33 -0400
Message-ID: <32596.1340212473@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1340212473_2019P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1340212473_2019P
Content-Type: text/plain; charset=us-ascii

Today's linux-next fails to build with CONFIG_NF_NAT_NEEDED=y and CONFIG_NF_NAT=m

  LD      init/built-in.o
net/built-in.o:(.data+0x4408): undefined reference to `nf_nat_tcp_seq_adjust'
make: *** [vmlinux] Error 1

Breakage introduced with this commit:

commit 8c88f87cb27ad09086940bdd3e6955e5325ec89a
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Thu Jun 7 13:31:25 2012 +0200

    netfilter: nfnetlink_queue: add NAT TCP sequence adjustment if packet mangled


--==_Exmh_1340212473_2019P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBT+IE+AdmEQWDXROgAQJdNA/+N50BjqMLNgcxiBH2K1cSC2Si6ijADt6E
DSEcYM6hHzgpEpJ/kN9vEOWvgHsyKKNQ3cJTmy3sxFquFTL32miRjEYSMZ0GD/Sv
eEKRCPWdBi2iH5vVXVrRaLMe0qk6utK81KWfLXt15h/IWyyCGpWdkaO389NZk7U/
Wy42qySOOSGItX2VPTnYlSgk7418rhaaf4/Gw/C1c1V08yeQbxcqonPxkpANhl7w
UW/BG03OrkW0kDrEEvPTLnNLCrBNjUHcHLSL19mYVM8H3QQZm12/iTXh1BK9Evw9
McSmCrAqS+O9l91sjrUJu+zCrbZYqaIUGCWhIhJi6teV/+17WPuivH5imfTn1LiV
ZtfF2kU4TzDmmSRkvwWvxLYzBzoGnMRtEoxX61kpo+HD8YCFl2Sv4cYsOBBh++I5
NYSSVTHzgr3saj198QtcwShBAYYV95Qj3i8EMgzRt2gjker5OmIA1Ilexo5TOpPW
XLUv8Nl5lutbl37o9NWGiRFqp4IpSgC1KLSmxI48TC5CVAieztoU8Az+4aEo93UY
GS28hPEUGJTs2vdJbl28PGHqjfYc6rzsBIikHSRRMUltZeOtYnmzeiCO9TyxqjMH
znNwx+vwa8pE7MBA8k8anb2Lr+nnmx/CmBtrhLk8/tapS4aCg1D4EDZQ4qldrJ6m
d+IRtF0qEJU=
=jIRo
-----END PGP SIGNATURE-----

--==_Exmh_1340212473_2019P--
