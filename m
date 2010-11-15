From: Joe Perches <joe@perches.com>
Subject: [PATCH 06/11] drivers/net/s2io.c: Remove unnecessary casts of pci_get_drvdata
Date: Mon, 15 Nov 2010 12:13:57 -0800
Message-ID: <5add1304ab2cd7f730a81a85598ef7357b087a86.1289851770.git.joe@perches.com>
References: <cover.1289851770.git.joe@perches.com>
Cc: Ramkrishna Vepa <ramkrishna.vepa@exar.com>,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Jon Mason <jon.mason@exar.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1289851770.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/s2io.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index ecc25aa..0f4219c 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -8321,8 +8321,7 @@ mem_alloc_failed:
 
 static void __devexit s2io_rem_nic(struct pci_dev *pdev)
 {
-	struct net_device *dev =
-		(struct net_device *)pci_get_drvdata(pdev);
+	struct net_device *dev = pci_get_drvdata(pdev);
 	struct s2io_nic *sp;
 
 	if (dev == NULL) {
-- 
1.7.3.1.g432b3.dirty
