From: Akash Shende <akash0x53s@gmail.com>
Subject: [PATCH 2/2] Drivers: Isdn: sc: Fixed coding style & spelling mistakes.
Date: Fri, 16 Jan 2015 19:12:42 +0530
Message-ID: <1421415762-21596-1-git-send-email-akash0x53s@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: isdn@linux-pingi.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix some spelling mistakes, coding style and don't assign value to static var.

Signed-off-by: Akash Shende <akash0x53s@gmail.com>
---
 drivers/isdn/sc/init.c | 15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/drivers/isdn/sc/init.c b/drivers/isdn/sc/init.c
index d6f19b1..3597ef4 100644
--- a/drivers/isdn/sc/init.c
+++ b/drivers/isdn/sc/init.c
@@ -30,7 +30,7 @@ static const char *boardname[] = { "DataCommute/BRI", "DataCommute/PRI", "TeleCo
 static unsigned int io[] = {0, 0, 0, 0};
 static unsigned char irq[] = {0, 0, 0, 0};
 static unsigned long ram[] = {0, 0, 0, 0};
-static bool do_reset = 0;
+static bool do_reset;
 
 module_param_array(io, int, NULL, 0);
 module_param_array(irq, byte, NULL, 0);
@@ -104,13 +104,12 @@ static int __init sc_init(void)
 					 io[b] + 0x400 * EXP_PAGE0);
 				continue;
 			}
-		}
-		else {
+		} else {
 			/*
 			 * Yes, probe for I/O Base
 			 */
 			if (probe_exhasted) {
-				pr_debug("All probe addresses exhasted, skipping\n");
+				pr_debug("All probe addresses exhausted, skipping\n");
 				continue;
 			}
 			pr_debug("Probing for I/O...\n");
@@ -169,8 +168,7 @@ static int __init sc_init(void)
 				model = identify_board(ram[b], io[b]);
 				release_region(ram[b], SRAM_PAGESIZE);
 			}
-		}
-		else {
+		} else {
 			/*
 			 * Yes, probe for free RAM and look for
 			 * a signature and id the board model
@@ -187,7 +185,7 @@ static int __init sc_init(void)
 						ram[b] = i;
 						break;
 					}
-					pr_debug("  Unidentifed or inaccessible\n");
+					pr_debug("  Unidentified or inaccessible\n");
 					continue;
 				}
 				pr_debug("  request failed\n");
@@ -337,8 +335,7 @@ static int __init sc_init(void)
 		sc_adapter[cinst]->interrupt = irq[b];
 		if (request_irq(sc_adapter[cinst]->interrupt, interrupt_handler,
 				0, interface->id,
-				(void *)(unsigned long) cinst))
-		{
+				(void *)(unsigned long) cinst)) {
 			kfree(sc_adapter[cinst]->channel);
 			indicate_status(cinst, ISDN_STAT_UNLOAD, 0, NULL);	/* Fix me */
 			kfree(interface);
-- 
2.2.2
