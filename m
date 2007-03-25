From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: [PATCH] zd1211rw: Mark some data const
Date: Mon, 26 Mar 2007 00:59:18 +0100 (BST)
Message-ID: <20070325235918.352527B409F@zog.reactivated.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a backport of Helge Deller's recent patch for wireless-dev.git

Signed-off-by: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
---
 zd_rf.c         |    2 +-
 zd_rf_al7230b.c |    4 ++--
 zd_rf_rf2959.c  |    4 ++--
 3 files changed, 5 insertions(+), 5 deletions(-)

Index: linux-zd1211rw/drivers/net/wireless/zd1211rw/zd_rf.c
===================================================================
--- linux-zd1211rw.orig/drivers/net/wireless/zd1211rw/zd_rf.c
+++ linux-zd1211rw/drivers/net/wireless/zd1211rw/zd_rf.c
@@ -23,7 +23,7 @@
 #include "zd_ieee80211.h"
 #include "zd_chip.h"
 
-static const char *rfs[] = {
+static const char * const rfs[] = {
 	[0]		= "unknown RF0",
 	[1]		= "unknown RF1",
 	[UW2451_RF]	= "UW2451_RF",
Index: linux-zd1211rw/drivers/net/wireless/zd1211rw/zd_rf_al7230b.c
===================================================================
--- linux-zd1211rw.orig/drivers/net/wireless/zd1211rw/zd_rf_al7230b.c
+++ linux-zd1211rw/drivers/net/wireless/zd1211rw/zd_rf_al7230b.c
@@ -183,12 +183,12 @@ static int al7230b_set_channel(struct zd
 	const u32 *rv = chan_rv[channel-1];
 	struct zd_chip *chip = zd_rf_to_chip(rf);
 
-	struct zd_ioreq16 ioreqs_1[] = {
+	static const struct zd_ioreq16 ioreqs_1[] = {
 		{ CR128, 0x14 }, { CR129, 0x12 }, { CR130, 0x10 },
 		{ CR38,  0x38 }, { CR136, 0xdf },
 	};
 
-	struct zd_ioreq16 ioreqs_2[] = {
+	static const struct zd_ioreq16 ioreqs_2[] = {
 		/* PLL_ON */
 		{ CR251, 0x3f },
 		{ CR203, 0x06 }, { CR240, 0x08 },
Index: linux-zd1211rw/drivers/net/wireless/zd1211rw/zd_rf_rf2959.c
===================================================================
--- linux-zd1211rw.orig/drivers/net/wireless/zd1211rw/zd_rf_rf2959.c
+++ linux-zd1211rw/drivers/net/wireless/zd1211rw/zd_rf_rf2959.c
@@ -21,7 +21,7 @@
 #include "zd_usb.h"
 #include "zd_chip.h"
 
-static u32 rf2959_table[][2] = {
+static const u32 rf2959_table[][2] = {
 	RF_CHANNEL( 1) = { 0x181979, 0x1e6666 },
 	RF_CHANNEL( 2) = { 0x181989, 0x1e6666 },
 	RF_CHANNEL( 3) = { 0x181999, 0x1e6666 },
@@ -228,7 +228,7 @@ static int rf2959_init_hw(struct zd_rf *
 static int rf2959_set_channel(struct zd_rf *rf, u8 channel)
 {
 	int i, r;
-	u32 *rv = rf2959_table[channel-1];
+	const u32 *rv = rf2959_table[channel-1];
 	struct zd_chip *chip = zd_rf_to_chip(rf);
 
 	for (i = 0; i < 2; i++) {
