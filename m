From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH v2 net-next 2/2] liquidio: cleanup: removed cryptic and
 misleading macro
Date: Mon, 24 Jul 2017 17:17:27 -0700
Message-ID: <20170725001727.GA1170@felix-thinkpad.cavium.com>
References: <20170725001559.GA1146@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0075.outbound.protection.outlook.com ([104.47.34.75]:19376
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755414AbdGYARi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Jul 2017 20:17:38 -0400
Content-Disposition: inline
In-Reply-To: <20170725001559.GA1146@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Farrington <ricardo.farrington@cavium.com>

Signed-off-by: Rick Farrington <ricardo.farrington@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/octeon_console.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_console.c b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
index 501ad95..0770183 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_console.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
@@ -42,8 +42,6 @@ module_param(console_bitmask, int, 0644);
 MODULE_PARM_DESC(console_bitmask,
 		 "Bitmask indicating which consoles have debug output redirected to syslog.");
 
-#define CAST_ULL(v) ((u64)(v))
-
 #define BOOTLOADER_PCI_READ_BUFFER_DATA_ADDR    0x0006c008
 #define BOOTLOADER_PCI_READ_BUFFER_LEN_ADDR     0x0006c004
 #define BOOTLOADER_PCI_READ_BUFFER_OWNER_ADDR   0x0006c000
@@ -233,7 +231,7 @@ static int __cvmx_bootmem_check_version(struct octeon_device *oct,
 	    (exact_match && major_version != exact_match)) {
 		dev_err(&oct->pci_dev->dev, "bootmem ver mismatch %d.%d addr:0x%llx\n",
 			major_version, minor_version,
-			CAST_ULL(oct->bootmem_desc_addr));
+			(long long)(oct->bootmem_desc_addr));
 		return -1;
 	} else {
 		return 0;
-- 
2.9.0
