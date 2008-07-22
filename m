From: Adrian Bunk <bunk@kernel.org>
Subject: [RFC: 2.6 patch] #if 0 bnx2x_override_led_value()
Date: Tue, 22 Jul 2008 20:20:18 +0300
Message-ID: <20080722172018.GM14846@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Yaniv Rosner <yanivr@broadcom.com>,
	Eilong Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5.pp.htv.fi ([213.243.153.39]:34747 "EHLO smtp5.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754540AbYGVRUa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2008 13:20:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch #if 0's bnx2x_override_led_value() that was added but is not 
used.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 drivers/net/bnx2x_link.c |    2 ++
 drivers/net/bnx2x_link.h |    2 --
 2 files changed, 2 insertions(+), 2 deletions(-)

faa4e9c8fe90a958323fc542b4abc768d6bdeb4e 
diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index ff2743d..8b10bcc 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -3433,6 +3433,7 @@ static void bnx2x_ext_phy_loopback(struct link_params *params)
 }
 
 
+#if 0
 /*
  *------------------------------------------------------------------------
  * bnx2x_override_led_value -
@@ -3547,6 +3548,7 @@ u8 bnx2x_override_led_value(struct bnx2x *bp, u8 port,
 
 	return 0;
 }
+#endif  /*  0  */
 
 
 u8 bnx2x_set_led(struct bnx2x *bp, u8 port, u8 mode, u32 speed,
diff --git a/drivers/net/bnx2x_link.h b/drivers/net/bnx2x_link.h
index 714d37a..33db685 100644
--- a/drivers/net/bnx2x_link.h
+++ b/drivers/net/bnx2x_link.h
@@ -156,8 +156,6 @@ u8 bnx2x_set_led(struct bnx2x *bp, u8 port, u8 mode, u32 speed,
 #define LED_MODE_OFF	0
 #define LED_MODE_OPER 	2
 
-u8 bnx2x_override_led_value(struct bnx2x *bp, u8 port, u32 led_idx, u32 value);
-
 u8 bnx2x_flash_download(struct bnx2x *bp, u8 port, u32 ext_phy_config,
 		      u8 driver_loaded, char data[], u32 size);
 /* Get the actual link status. In case it returns 0, link is up,

