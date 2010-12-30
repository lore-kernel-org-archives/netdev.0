From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: [PATCH 15/15]drivers:spi:dw_spi.c Typo change diable to disable.
Date: Thu, 30 Dec 2010 15:08:04 -0800
Message-ID: <1293750484-1161-15-git-send-email-justinmattock@gmail.com>
References: <1293750484-1161-1-git-send-email-justinmattock@gmail.com>
 <1293750484-1161-2-git-send-email-justinmattock@gmail.com>
 <1293750484-1161-3-git-send-email-justinmattock@gmail.com>
 <1293750484-1161-4-git-send-email-justinmattock@gmail.com>
 <1293750484-1161-5-git-send-email-justinmattock@gmail.com>
 <1293750484-1161-6-git-send-email-justinmattock@gmail.com>
 <1293750484-1161-7-git-send-email-justinmattock@gmail.com>
 <1293750484-1161-8-git-send-email-justinmattock@gmail.com>
 <1293750484-1161-9-git-send-email-justinmattock@gmail.com>
 <1293750484-1161-10-git-send-email-justinmattock@gmail.com>
 <1293750484-1161-11-git-send-email-justinmattock@gmail.com>
 <1293750484-1161-12-git-send-email-justinmattock@gmail.com>
 <1293750484-1161-13-git-send-email-justinmattock@gmail.com>
 <1293750484-1161-14-git-send-email-justinmattock@gmail.com>
Cc: linux-m68k@lists.linux-m68k.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, ivtv-devel@ivtvdriver.org,
	linux-media@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-scsi@vger.kernel.org,
	spi-devel-general@lists.sourceforge.net,
	devel@driverdev.osuosl.org, linux-usb@vger.kernel.org,
	"Justin P. Mattock" <justinmattock@gmail.com>
To: trivial@kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1293750484-1161-14-git-send-email-justinmattock@gmail.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The below patch fixes a typo "diable" to "disable". Please let me know if this
is correct or not.

Signed-off-by: Justin P. Mattock <justinmattock@gmail.com>

---
 drivers/spi/dw_spi.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/spi/dw_spi.c b/drivers/spi/dw_spi.c
index 7c3cf21..a3a065f 100644
--- a/drivers/spi/dw_spi.c
+++ b/drivers/spi/dw_spi.c
@@ -910,12 +910,12 @@ int __devinit dw_spi_add_host(struct dw_spi *dws)
 	ret = init_queue(dws);
 	if (ret) {
 		dev_err(&master->dev, "problem initializing queue\n");
-		goto err_diable_hw;
+		goto err_disable_hw;
 	}
 	ret = start_queue(dws);
 	if (ret) {
 		dev_err(&master->dev, "problem starting queue\n");
-		goto err_diable_hw;
+		goto err_disable_hw;
 	}
 
 	spi_master_set_devdata(master, dws);
@@ -930,7 +930,7 @@ int __devinit dw_spi_add_host(struct dw_spi *dws)
 
 err_queue_alloc:
 	destroy_queue(dws);
-err_diable_hw:
+err_disable_hw:
 	spi_enable_chip(dws, 0);
 	free_irq(dws->irq, dws);
 err_free_master:
-- 
1.6.5.2.180.gc5b3e

