From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: add missing strings in oct_dev_state_str
 array
Date: Thu, 3 Aug 2017 13:08:24 -0700
Message-ID: <20170803200824.GA2312@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        intiyaz.basha@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0051.outbound.protection.outlook.com ([104.47.42.51]:20319
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751696AbdHCUIc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Aug 2017 16:08:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Intiyaz Basha <intiyaz.basha@cavium.com>

There's supposed to be a one-to-one correspondence between the 18 macros
that #define the OCT_DEV states (in octeon_device.h) and the strings in the
oct_dev_state_str array, but there are only 14 strings in the array.

Add the missing strings (so they become 18 in total), and also revise some
incorrect/outdated text of existing strings.

Signed-off-by: Intiyaz Basha <intiyaz.basha@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/octeon_device.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index f10014f7..495cc88 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -528,9 +528,10 @@ static struct octeon_config_ptr {
 };
 
 static char oct_dev_state_str[OCT_DEV_STATES + 1][32] = {
-	"BEGIN", "PCI-MAP-DONE", "DISPATCH-INIT-DONE",
+	"BEGIN", "PCI-ENABLE-DONE", "PCI-MAP-DONE", "DISPATCH-INIT-DONE",
 	"IQ-INIT-DONE", "SCBUFF-POOL-INIT-DONE", "RESPLIST-INIT-DONE",
-	"DROQ-INIT-DONE", "IO-QUEUES-INIT-DONE", "CONSOLE-INIT-DONE",
+	"DROQ-INIT-DONE", "MBOX-SETUP-DONE", "MSIX-ALLOC-VECTOR-DONE",
+	"INTR-SET-DONE", "IO-QUEUES-INIT-DONE", "CONSOLE-INIT-DONE",
 	"HOST-READY", "CORE-READY", "RUNNING", "IN-RESET",
 	"INVALID"
 };
