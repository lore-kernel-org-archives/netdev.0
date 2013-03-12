From: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
Subject: [PATCH] ethernet: amd: use PTR_RET instead of IS_ERR + PTR_ERR
Date: Tue, 12 Mar 2013 09:48:07 +0200
Message-ID: <1363074487-21248-1-git-send-email-silviupopescu1990@gmail.com>
Cc: davem@davemloft.net, geert@linux-m68k.org, joe@perches.com,
	dhowells@redhat.com, linux-kernel@vger.kernel.org,
	Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This uses PTR_RET instead of IS_ERR and PTR_ERR in order to increase
readability.

Signed-off-by: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
---
 drivers/net/ethernet/amd/atarilance.c |    4 +---
 drivers/net/ethernet/amd/mvme147.c    |    4 +---
 drivers/net/ethernet/amd/ni65.c       |    2 +-
 drivers/net/ethernet/amd/sun3lance.c  |    4 +---
 4 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/amd/atarilance.c b/drivers/net/ethernet/amd/atarilance.c
index ab9bedb..e8d0ef5 100644
--- a/drivers/net/ethernet/amd/atarilance.c
+++ b/drivers/net/ethernet/amd/atarilance.c
@@ -1147,9 +1147,7 @@ static struct net_device *atarilance_dev;
 static int __init atarilance_module_init(void)
 {
 	atarilance_dev = atarilance_probe(-1);
-	if (IS_ERR(atarilance_dev))
-		return PTR_ERR(atarilance_dev);
-	return 0;
+	return PTR_RET(atarilance_dev);
 }
 
 static void __exit atarilance_module_exit(void)
diff --git a/drivers/net/ethernet/amd/mvme147.c b/drivers/net/ethernet/amd/mvme147.c
index 9af3c30..a51497c 100644
--- a/drivers/net/ethernet/amd/mvme147.c
+++ b/drivers/net/ethernet/amd/mvme147.c
@@ -188,9 +188,7 @@ static struct net_device *dev_mvme147_lance;
 int __init init_module(void)
 {
 	dev_mvme147_lance = mvme147lance_probe(-1);
-	if (IS_ERR(dev_mvme147_lance))
-		return PTR_ERR(dev_mvme147_lance);
-	return 0;
+	return PTR_RET(dev_mvme147_lance);
 }
 
 void __exit cleanup_module(void)
diff --git a/drivers/net/ethernet/amd/ni65.c b/drivers/net/ethernet/amd/ni65.c
index 013b651..26fc0ce 100644
--- a/drivers/net/ethernet/amd/ni65.c
+++ b/drivers/net/ethernet/amd/ni65.c
@@ -1238,7 +1238,7 @@ MODULE_PARM_DESC(dma, "ni6510 ISA DMA channel (ignored for some cards)");
 int __init init_module(void)
 {
  	dev_ni65 = ni65_probe(-1);
-	return IS_ERR(dev_ni65) ? PTR_ERR(dev_ni65) : 0;
+	return PTR_RET(dev_ni65);
 }
 
 void __exit cleanup_module(void)
diff --git a/drivers/net/ethernet/amd/sun3lance.c b/drivers/net/ethernet/amd/sun3lance.c
index de412d3..4375abe 100644
--- a/drivers/net/ethernet/amd/sun3lance.c
+++ b/drivers/net/ethernet/amd/sun3lance.c
@@ -940,9 +940,7 @@ static struct net_device *sun3lance_dev;
 int __init init_module(void)
 {
 	sun3lance_dev = sun3lance_probe(-1);
-	if (IS_ERR(sun3lance_dev))
-		return PTR_ERR(sun3lance_dev);
-	return 0;
+	return PTR_RET(sun3lance_dev);
 }
 
 void __exit cleanup_module(void)
-- 
1.7.9.5
