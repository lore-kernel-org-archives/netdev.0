From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 0/3] Remove the inet_lro library
Date: Mon, 15 Feb 2016 21:23:52 +0000
Message-ID: <20160215212351.GB5231@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="l76fUT7nc3MelDdI"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:36440 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751104AbcBOVXx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 16:23:53 -0500
Received: from ben by shadbolt.decadent.org.uk with local (Exim 4.84)
	(envelope-from <ben@decadent.org.uk>)
	id 1aVQca-0001VR-61
	for netdev@vger.kernel.org; Mon, 15 Feb 2016 21:23:52 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--l76fUT7nc3MelDdI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

The old inet_lro library has been deprecated ever since GRO was
introduced, but there are still a few drivers using it.  Convert
them to GRO and remove it.

Ben.

Ben Hutchings (3):
  pasemi_mac: Replace LRO with GRO
  RDMA/nes: Replace LRO with GRO
  ipv4: Remove inet_lro library

 drivers/infiniband/hw/nes/Kconfig                |   1 -
 drivers/infiniband/hw/nes/nes_hw.c               |  44 +--
 drivers/infiniband/hw/nes/nes_hw.h               |   7 -
 drivers/infiniband/hw/nes/nes_nic.c              |   7 -
 drivers/net/ethernet/pasemi/Kconfig              |   5 +-
 drivers/net/ethernet/pasemi/pasemi_mac.c         |  50 +--
 drivers/net/ethernet/pasemi/pasemi_mac.h         |   4 -
 drivers/net/ethernet/pasemi/pasemi_mac_ethtool.c |   1 -
 include/linux/inet_lro.h                         | 142 ---------
 net/ipv4/Kconfig                                 |   8 -
 net/ipv4/Makefile                                |   1 -
 net/ipv4/inet_lro.c                              | 374 -----------------------
 12 files changed, 4 insertions(+), 640 deletions(-)
 delete mode 100644 include/linux/inet_lro.h
 delete mode 100644 net/ipv4/inet_lro.c


--l76fUT7nc3MelDdI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUBVsJB5+e/yOyVhhEJAQqdDhAAi8kKarvR03DFe2TCu/G3OZu71wswxcg8
JQwOAXeHy7BkD0oVkjTw8vMN8T8krbKZDTC2dML+HDw3M/JvGkItS4wWcI5MqHS5
miIQG+aUEawvBiF6XyoZB9p6bR7SsGRF36eMYyspspPXL6YucziCElKzlx5EJacA
g+J/PpmXud7OlFoBYo5CzmFJnlNRx233DvOs4lpHcXggGpDRuGvm8mdN+nnEyWjs
Mpvg65k21mT/woYbXgTHpd1pi36oNsrGDPKNFIJhbqvAZMPmqGimVwwZ7wKiRQqc
SG6bN+4X7Cmkk3YImgB4lYhZun5MhgLpVvIrQdBMvzTRzQuLYtKjCAiDqHWCcuVh
X/GFJaL1bfysR2WI2Lx7WbEM9IIq0QYwy0Bo5m+6YTZKStrDSm73wjD3UI0tc+TN
4+A3JYjvj1CnMKhhU+KjIQavFSrWgCEsppBsYVWZC4YOCbSZYN3e88cb0xIaBlKn
e4soDxTQJphApB98c91i6i6nyfMJ/nMsxg/w8w2CYBTmoSSpNmyekQhoGA0hem93
ZXU6XKrff51kStbGr1xexnbYt2wR5O6+8s92db5G8nJbl1L1/caL9pPSNFUwX9tP
+JzqoWxvW9dLYF7dx1vzsP0sew0ZpMfkJH/GxUrqZFVZ6L8XCbnVllUoJiMWB9gl
CiPZMlz1D3o=
=IUQk
-----END PGP SIGNATURE-----

--l76fUT7nc3MelDdI--
