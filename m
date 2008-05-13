From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 2/2] s2io: add missing block braces to multistatement if statement
Date: Tue, 13 May 2008 14:16:54 +0300
Message-ID: <1210677414-16380-2-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1210677414-16380-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>,
	Ramkrishna Vepa <ram.vepa@neterion.com>,
	Rastapur Santosh <santosh.rastapur@neterion.com>,
	Sivakumar Subramani <sivakumar.subramani@neterion.com>,
	Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33762 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751630AbYEMLQz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 07:16:55 -0400
In-Reply-To: <1210677414-16380-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
Cc: Ramkrishna Vepa <ram.vepa@neterion.com>
Cc: Rastapur Santosh <santosh.rastapur@neterion.com>
Cc: Sivakumar Subramani <sivakumar.subramani@neterion.com>
Cc: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
---
 drivers/net/s2io.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 523478e..0f3d230 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -1113,9 +1113,10 @@ static int s2io_on_nec_bridge(struct pci_dev *s2=
io_pdev)
 	struct pci_dev *tdev =3D NULL;
 	while ((tdev =3D pci_get_device(PCI_ANY_ID, PCI_ANY_ID, tdev)) !=3D N=
ULL) {
 		if (tdev->vendor =3D=3D NEC_VENID && tdev->device =3D=3D NEC_DEVID) =
{
-			if (tdev->bus =3D=3D s2io_pdev->bus->parent)
+			if (tdev->bus =3D=3D s2io_pdev->bus->parent) {
 				pci_dev_put(tdev);
 				return 1;
+			}
 		}
 	}
 	return 0;
--=20
1.5.2.2

