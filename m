From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree (net-next
 tree related)
Date: Mon, 20 Feb 2012 16:15:45 +1100
Message-ID: <20120220161545.0078a76d8050c56955427455@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__20_Feb_2012_16_15_45_+1100_UnO0QyCOdsVeVmu5"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Danny Kukawka <danny.kukawka@bisect.de>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from haggis.pcug.org.au ([203.10.76.10]:38689 "EHLO
	members.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707Ab2BTFP7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2012 00:15:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Mon__20_Feb_2012_16_15_45_+1100_UnO0QyCOdsVeVmu5
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the final tree, today's linux-next build (powerpc
allyesconfig) failed like this:

drivers/net/ethernet/xilinx/ll_temac_main.c: In function 'temac_set_mac_add=
ress':
drivers/net/ethernet/xilinx/ll_temac_main.c:332:3: error: 'dev' undeclared =
(first use in this function)

Caused by commit 5a5e7c364486 ("xilinx ll_temac: use eth_hw_addr_random()
instead of random_ether_addr()").

I have reverted that commit for today.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Mon__20_Feb_2012_16_15_45_+1100_UnO0QyCOdsVeVmu5
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJPQdcBAAoJEECxmPOUX5FE7wQP/3zrbic5eLdwCYc6U4dWz4HW
s6MPHgnFYR2TXGfxEh9iv/Bo5fbkIoRHx0b6IA0Xf+HEIH6KcrPAJ0cTtB8y5jyu
/nCwpIL6B53bYYBS+jHj7VOaXdhIfC/aHJv8bjhWX9oWhwcRTDfEozv6QD20VlXn
d5hx4Z4mseCouuirE4sqa5NYipl3bRFK79wqiut8JtTp7ibwsreh8mUwBAgSADem
zif+LUZ+ffpCxhl0bg8LmXA9WfZ056TW0SoGAHtLXp7lIOfm8WimJQ5Vz/475fmh
VJGUu3v/yC/xxaR92Fgc4kV4zSE+FOIhVx53mrBWE+mL19603AoZz4epT5OyePcw
lnmtlHEiH2oHT+ap3o7rAZ8wIi7UHqhaZsbcJ9363vqQtU0Tzkx2ZYXioPSASJXM
gbqCNQ6QGxagzCT45rAMxzsf6xHGD6G5ynDGWfgMObOcbrC8oRzDbSzeVhkTdMFn
IfVTGU4IcMk1Mi9lcoHcuADvpOncerLU7iXMVST6rijOx3DQA88F5YFf1u0tzu4g
7+A1AIa20gdZUd41+0cKLylYm3CAAj8IG8+yrSQVTjg/9snc7EDGhjGxUC9LuFdZ
TAl4noGVJvIynCsEKonw335hbyCPchuihzGFImwwTfr0EeKzYaH8s4FSbcaHqysH
Lrbxz2mUnn5AxJlVCSb8
=oegM
-----END PGP SIGNATURE-----

--Signature=_Mon__20_Feb_2012_16_15_45_+1100_UnO0QyCOdsVeVmu5--
