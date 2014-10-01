From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH v2] net: ll_temac: Remove unnecessary ether_setup after alloc_etherdev
Date: Wed,  1 Oct 2014 11:01:17 +0200
Message-ID: <909ad6e2f067c956a2bb89d848a2fc38fc605a08.1412154072.git.michal.simek@xilinx.com>
Content-Type: multipart/signed;
    boundary="=_mimegpg-monstr-desktop-3880-1412154077-0001";
    micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Subbaraya Sundeep Bhatta <subbaraya.sundeep.bhatta@xilinx.com>,
	"David S. Miller" <davem@davemloft.net>,
	=?UTF-8?q?Manuel=20Sch=C3=B6lling?= <manuel.schoelling@gmx.de>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Julia Lawall <Julia.Lawall@lip6.fr>,
	Joe Perches <joe@perches.com>,
	Ricardo Ribalda <ricardo.ribalda@gmail.com>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: linux-kernel@vger.kernel.org, monstr@monstr.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:34733 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751195AbaJAJBZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 05:01:25 -0400
Received: by mail-wi0-f180.google.com with SMTP id em10so1079133wid.1
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 02:01:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a MIME GnuPG-signed message.  If you see this text, it means that
your E-mail or Usenet software does not support MIME signed messages.
The Internet standard for MIME PGP messages, RFC 2015, was published in 1996.
To open this message correctly you will need to install E-mail or Usenet
software that supports modern Internet standards.

--=_mimegpg-monstr-desktop-3880-1412154077-0001

From: Subbaraya Sundeep Bhatta <subbaraya.sundeep.bhatta@xilinx.com>

Calling ether_setup is redundant since alloc_etherdev calls it.

Signed-off-by: Subbaraya Sundeep Bhatta <sbhatta@xilinx.com>
Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---

Changes in v2:
- Remove axienet because it is already applied in separate patch
  https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=c706471b2601d1c9058e7b866db77f6eb7dd37af

 drivers/net/ethernet/xilinx/ll_temac_main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index fda5891835d4..629077050fce 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -1012,7 +1012,6 @@ static int temac_of_probe(struct platform_device *op)
 	if (!ndev)
 		return -ENOMEM;

-	ether_setup(ndev);
 	platform_set_drvdata(op, ndev);
 	SET_NETDEV_DEV(ndev, &op->dev);
 	ndev->flags &= ~IFF_MULTICAST;  /* clear multicast */
--
1.8.2.3


--=_mimegpg-monstr-desktop-3880-1412154077-0001
Content-Type: application/pgp-signature
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAlQrwt0ACgkQykllyylKDCEL6wCgiGNqZfYOFZtg8Uv8wDjAeyXN
LGAAni1vsqlO2rImzJ5A/GHa3dR3YVl7
=wD1e
-----END PGP SIGNATURE-----

--=_mimegpg-monstr-desktop-3880-1412154077-0001--
