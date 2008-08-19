From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] s2io: reindented misleading for loop
Date: Tue, 19 Aug 2008 10:36:01 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0808191034490.4551@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-2067999932-1219131361=:4551"
Cc: Netdev <netdev@vger.kernel.org>
To: ram.vepa@neterion.com, Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46177 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752454AbYHSHgD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 03:36:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-2067999932-1219131361=:4551
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 drivers/net/s2io.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index a2b0730..243db33 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -8175,8 +8175,8 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 		    break;
 	}
 	if (sp->config.multiq) {
-	for (i = 0; i < sp->config.tx_fifo_num; i++)
-		mac_control->fifos[i].multiq = config->multiq;
+		for (i = 0; i < sp->config.tx_fifo_num; i++)
+			mac_control->fifos[i].multiq = config->multiq;
 		DBG_PRINT(ERR_DBG, "%s: Multiqueue support enabled\n",
 			dev->name);
 	} else
-- 
1.5.2.2

---696208474-2067999932-1219131361=:4551--
