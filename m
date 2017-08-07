From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: fix misspelled firmware image filenames
Date: Mon, 7 Aug 2017 12:22:15 -0700
Message-ID: <20170807192215.GA1302@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0065.outbound.protection.outlook.com ([104.47.38.65]:29403
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751775AbdHGTWY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 7 Aug 2017 15:22:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Derek Chickles <derek.chickles@cavium.com>

Fix misspelled firmware image filenames advertised via MODULE_FIRMWARE().

Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 8c2cd80..3ec0dd9 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -39,10 +39,14 @@ MODULE_AUTHOR("Cavium Networks, <support@cavium.com>");
 MODULE_DESCRIPTION("Cavium LiquidIO Intelligent Server Adapter Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(LIQUIDIO_VERSION);
-MODULE_FIRMWARE(LIO_FW_DIR LIO_FW_BASE_NAME LIO_210SV_NAME LIO_FW_NAME_SUFFIX);
-MODULE_FIRMWARE(LIO_FW_DIR LIO_FW_BASE_NAME LIO_210NV_NAME LIO_FW_NAME_SUFFIX);
-MODULE_FIRMWARE(LIO_FW_DIR LIO_FW_BASE_NAME LIO_410NV_NAME LIO_FW_NAME_SUFFIX);
-MODULE_FIRMWARE(LIO_FW_DIR LIO_FW_BASE_NAME LIO_23XX_NAME LIO_FW_NAME_SUFFIX);
+MODULE_FIRMWARE(LIO_FW_DIR LIO_FW_BASE_NAME LIO_210SV_NAME
+		"_" LIO_FW_NAME_TYPE_NIC LIO_FW_NAME_SUFFIX);
+MODULE_FIRMWARE(LIO_FW_DIR LIO_FW_BASE_NAME LIO_210NV_NAME
+		"_" LIO_FW_NAME_TYPE_NIC LIO_FW_NAME_SUFFIX);
+MODULE_FIRMWARE(LIO_FW_DIR LIO_FW_BASE_NAME LIO_410NV_NAME
+		"_" LIO_FW_NAME_TYPE_NIC LIO_FW_NAME_SUFFIX);
+MODULE_FIRMWARE(LIO_FW_DIR LIO_FW_BASE_NAME LIO_23XX_NAME
+		"_" LIO_FW_NAME_TYPE_NIC LIO_FW_NAME_SUFFIX);
 
 static int ddr_timeout = 10000;
 module_param(ddr_timeout, int, 0644);
