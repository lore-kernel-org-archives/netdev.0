From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] horizon: make reset function not __init
Date: Thu, 19 Feb 2004 15:49:41 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040219154941.0d0f5a7a.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Please apply to 2.6.current.

product_versions: linux-263
description:	This function can be called by init or exit code,
		so it shouldn't be marked __init.

diffstat:=
 drivers/atm/horizon.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)


diff -Naurp ./drivers/atm/horizon.c~hrzinit ./drivers/atm/horizon.c
--- ./drivers/atm/horizon.c~hrzinit	2004-02-17 19:57:11.000000000 -0800
+++ ./drivers/atm/horizon.c	2004-02-19 15:19:18.000000000 -0800
@@ -1802,7 +1802,7 @@ static int hrz_send (struct atm_vcc * at
 
 /********** reset a card **********/
 
-static void __init hrz_reset (const hrz_dev * dev) {
+static void hrz_reset (const hrz_dev * dev) {
   u32 control_0_reg = rd_regl (dev, CONTROL_0_REG);
   
   // why not set RESET_HORIZON to one and wait for the card to


--
~Randy
