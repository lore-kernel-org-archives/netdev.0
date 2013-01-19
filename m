From: Jon Mason <jon.mason@intel.com>
Subject: [PATCH 16/21] ntb_netdev: remove init/exit from probe/remove
Date: Sat, 19 Jan 2013 02:02:30 -0700
Message-ID: <1358586155-23322-17-git-send-email-jon.mason@intel.com>
References: <1358586155-23322-1-git-send-email-jon.mason@intel.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dave Jiang <dave.jiang@intel.com>,
	Nicholas Bellinger <nab@linux-iscsi.org>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358586155-23322-1-git-send-email-jon.mason@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove init/exit from probe/remove routines to correct warnings of
"Section mismatch".

Signed-off-by: Jon Mason <jon.mason@intel.com>
---
 drivers/net/ntb_netdev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ntb_netdev.c b/drivers/net/ntb_netdev.c
index 4e52fd2..0d4a6ee 100644
--- a/drivers/net/ntb_netdev.c
+++ b/drivers/net/ntb_netdev.c
@@ -373,7 +373,7 @@ err:
 	return rc;
 }
 
-static void __exit ntb_netdev_remove(struct pci_dev *pdev)
+static void ntb_netdev_remove(struct pci_dev *pdev)
 {
 	struct net_device *ndev;
 	struct ntb_netdev *dev;
-- 
1.7.9.5
