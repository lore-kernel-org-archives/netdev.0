From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] [trivial] stmmac: Fix typo in stmmac_pci.c
Date: Wed,  8 Feb 2012 21:08:21 +0900
Message-ID: <1328702901-2157-1-git-send-email-standby24x7@gmail.com>
Cc: linux-kernel@vger.kernel.org, trivial@kernel.org,
	standby24x7@gmail.com
To: peppe.cavallaro@st.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Correct spelling "regiser" to "register" in
drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index c796de9..6ce0706 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -85,7 +85,7 @@ static int __devinit stmmac_pci_probe(struct pci_dev *pdev,
 			continue;
 		addr = pci_iomap(pdev, i, 0);
 		if (addr == NULL) {
-			pr_err("%s: ERROR: cannot map regiser memory, aborting",
+			pr_err("%s: ERROR: cannot map register memory, aborting",
 			       __func__);
 			ret = -EIO;
 			goto err_out_map_failed;
-- 
1.7.6.5
