From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] atl1e: multistatement if missing braces
Date: Tue, 19 Aug 2008 10:32:06 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0808191029460.4551@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-2008989076-1219131126=:4551"
Cc: Netdev <netdev@vger.kernel.org>
To: Jie Yang <jie.yang@atheros.com>, Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:50988 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752292AbYHSHcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 03:32:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-2008989076-1219131126=:4551
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


Doesn't cause problems (yet) because err gets zeroed earlier.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 drivers/net/atl1e/atl1e_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_main.c
index 82d7be1..7685b99 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -2232,10 +2232,11 @@ static int atl1e_resume(struct pci_dev *pdev)
 
 	AT_WRITE_REG(&adapter->hw, REG_WOL_CTRL, 0);
 
-	if (netif_running(netdev))
+	if (netif_running(netdev)) {
 		err = atl1e_request_irq(adapter);
 		if (err)
 			return err;
+	}
 
 	atl1e_reset_hw(&adapter->hw);
 
-- 
1.5.2.2

---696208474-2008989076-1219131126=:4551--
