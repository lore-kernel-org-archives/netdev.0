From: Jon Mason <jon.mason@intel.com>
Subject: [PATCH 08/21] NTB: declare unused variables
Date: Sat, 19 Jan 2013 02:02:22 -0700
Message-ID: <1358586155-23322-9-git-send-email-jon.mason@intel.com>
References: <1358586155-23322-1-git-send-email-jon.mason@intel.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dave Jiang <dave.jiang@intel.com>,
	Nicholas Bellinger <nab@linux-iscsi.org>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358586155-23322-1-git-send-email-jon.mason@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tag pci_device_id in ntb_pci_probe as unused function parameters.  This
corrects issues found by 'EXTRA_CFLAGS=-W'.

Signed-off-by: Jon Mason <jon.mason@intel.com>
---
 drivers/ntb/ntb_hw.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/ntb/ntb_hw.c b/drivers/ntb/ntb_hw.c
index 867ccaa..2357c2d 100644
--- a/drivers/ntb/ntb_hw.c
+++ b/drivers/ntb/ntb_hw.c
@@ -1007,7 +1007,8 @@ static void ntb_free_callbacks(struct ntb_device *ndev)
 	kfree(ndev->db_cb);
 }
 
-static int ntb_pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
+static int ntb_pci_probe(struct pci_dev *pdev,
+			 __attribute__((unused)) const struct pci_device_id *id)
 {
 	struct ntb_device *ndev;
 	int rc, i;
-- 
1.7.9.5
