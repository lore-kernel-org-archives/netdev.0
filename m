From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [PATCH 1/2] iproute2: can: fix indention white spaces
Date: Wed, 23 Apr 2014 19:27:26 +0200
Message-ID: <1398274047-5407-2-git-send-email-socketcan@hartkopp.net>
References: <1398274047-5407-1-git-send-email-socketcan@hartkopp.net>
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	Oliver Hartkopp <socketcan@hartkopp.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.220]:17011 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757674AbaDWR14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 13:27:56 -0400
In-Reply-To: <1398274047-5407-1-git-send-email-socketcan@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When preparing a patch for CAN FD support these white space issues showed up.
Fix it in the current code to be able to provide a proper follow up patch.

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
---
 ip/iplink_can.c | 72 ++++++++++++++++++++++++++++-----------------------------
 1 file changed, 36 insertions(+), 36 deletions(-)

diff --git a/ip/iplink_can.c b/ip/iplink_can.c
index 1d3d09c..66e6c0e 100644
--- a/ip/iplink_can.c
+++ b/ip/iplink_can.c
@@ -1,12 +1,12 @@
 /*
  * iplink_can.c	CAN device support
  *
- *              This program is free software; you can redistribute it and/or
- *              modify it under the terms of the GNU General Public License
- *              as published by the Free Software Foundation; either version
- *              2 of the License, or (at your option) any later version.
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
  *
- * Authors:     Wolfgang Grandegger <wg@grandegger.com>
+ * Authors:	Wolfgang Grandegger <wg@grandegger.com>
  */
 
 #include <stdio.h>
@@ -23,27 +23,27 @@ static void usage(void)
 {
 	fprintf(stderr,
 		"Usage: ip link set DEVICE type can\n"
-	        "\t[ bitrate BITRATE [ sample-point SAMPLE-POINT] ] | \n"
-	        "\t[ tq TQ prop-seg PROP_SEG phase-seg1 PHASE-SEG1\n "
+		"\t[ bitrate BITRATE [ sample-point SAMPLE-POINT] ] | \n"
+		"\t[ tq TQ prop-seg PROP_SEG phase-seg1 PHASE-SEG1\n "
 		"\t  phase-seg2 PHASE-SEG2 [ sjw SJW ] ]\n"
 		"\n"
-	        "\t[ loopback { on | off } ]\n"
-	        "\t[ listen-only { on | off } ]\n"
-	        "\t[ triple-sampling { on | off } ]\n"
-	        "\t[ one-shot { on | off } ]\n"
-	        "\t[ berr-reporting { on | off } ]\n"
+		"\t[ loopback { on | off } ]\n"
+		"\t[ listen-only { on | off } ]\n"
+		"\t[ triple-sampling { on | off } ]\n"
+		"\t[ one-shot { on | off } ]\n"
+		"\t[ berr-reporting { on | off } ]\n"
 		"\n"
-	        "\t[ restart-ms TIME-MS ]\n"
-	        "\t[ restart ]\n"
+		"\t[ restart-ms TIME-MS ]\n"
+		"\t[ restart ]\n"
 		"\n"
-		"\tWhere: BITRATE       := { 1..1000000 }\n"
-		"\t       SAMPLE-POINT  := { 0.000..0.999 }\n"
-		"\t       TQ            := { NUMBER }\n"
-		"\t       PROP-SEG      := { 1..8 }\n"
-		"\t       PHASE-SEG1    := { 1..8 }\n"
-		"\t       PHASE-SEG2    := { 1..8 }\n"
-		"\t       SJW           := { 1..4 }\n"
-		"\t       RESTART-MS    := { 0 | NUMBER }\n"
+		"\tWhere: BITRATE	:= { 1..1000000 }\n"
+		"\t	  SAMPLE-POINT	:= { 0.000..0.999 }\n"
+		"\t	  TQ		:= { NUMBER }\n"
+		"\t	  PROP-SEG	:= { 1..8 }\n"
+		"\t	  PHASE-SEG1	:= { 1..8 }\n"
+		"\t	  PHASE-SEG2	:= { 1..8 }\n"
+		"\t	  SJW		:= { 1..4 }\n"
+		"\t	  RESTART-MS	:= { 0 | NUMBER }\n"
 		);
 }
 
@@ -185,12 +185,12 @@ static int can_parse_opt(struct link_util *lu, int argc, char **argv,
 }
 
 static const char *can_state_names[] = {
-		[CAN_STATE_ERROR_ACTIVE] = "ERROR-ACTIVE",
-		[CAN_STATE_ERROR_WARNING] = "ERROR-WARNING",
-		[CAN_STATE_ERROR_PASSIVE] = "ERROR-PASSIVE",
-		[CAN_STATE_BUS_OFF] = "BUS-OFF",
-		[CAN_STATE_STOPPED] = "STOPPED",
-		[CAN_STATE_SLEEPING] = "SLEEPING"
+	[CAN_STATE_ERROR_ACTIVE] = "ERROR-ACTIVE",
+	[CAN_STATE_ERROR_WARNING] = "ERROR-WARNING",
+	[CAN_STATE_ERROR_PASSIVE] = "ERROR-PASSIVE",
+	[CAN_STATE_BUS_OFF] = "BUS-OFF",
+	[CAN_STATE_STOPPED] = "STOPPED",
+	[CAN_STATE_SLEEPING] = "SLEEPING"
 };
 
 static void can_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
@@ -228,10 +228,10 @@ static void can_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	if (tb[IFLA_CAN_BITTIMING]) {
 		struct can_bittiming *bt = RTA_DATA(tb[IFLA_CAN_BITTIMING]);
 
-		fprintf(f, "\n    "
+		fprintf(f, "\n	  "
 			"bitrate %d sample-point %.3f ",
-		        bt->bitrate, (float)bt->sample_point / 1000.);
-		fprintf(f, "\n    "
+			bt->bitrate, (float)bt->sample_point / 1000.);
+		fprintf(f, "\n	  "
 			"tq %d prop-seg %d phase-seg1 %d phase-seg2 %d sjw %d",
 			bt->tq, bt->prop_seg, bt->phase_seg1, bt->phase_seg2,
 			bt->sjw);
@@ -241,10 +241,10 @@ static void can_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		struct can_bittiming_const *btc =
 			RTA_DATA(tb[IFLA_CAN_BITTIMING_CONST]);
 
-		fprintf(f, "\n    "
+		fprintf(f, "\n	  "
 			"%s: tseg1 %d..%d tseg2 %d..%d "
 			"sjw 1..%d brp %d..%d brp-inc %d",
-		        btc->name, btc->tseg1_min, btc->tseg1_max,
+			btc->name, btc->tseg1_min, btc->tseg1_max,
 			btc->tseg2_min, btc->tseg2_max, btc->sjw_max,
 			btc->brp_min, btc->brp_max, btc->brp_inc);
 	}
@@ -252,7 +252,7 @@ static void can_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	if (tb[IFLA_CAN_CLOCK]) {
 		struct can_clock *clock = RTA_DATA(tb[IFLA_CAN_CLOCK]);
 
-		fprintf(f, "\n    clock %d", clock->freq);
+		fprintf(f, "\n	  clock %d", clock->freq);
 	}
 
 }
@@ -264,10 +264,10 @@ static void can_print_xstats(struct link_util *lu,
 
 	if (xstats && RTA_PAYLOAD(xstats) == sizeof(*stats)) {
 		stats = RTA_DATA(xstats);
-		fprintf(f, "\n    "
+		fprintf(f, "\n	  "
 			"re-started bus-errors arbit-lost "
 			"error-warn error-pass bus-off");
-		fprintf(f, "\n    %-10d %-10d %-10d %-10d %-10d %-10d",
+		fprintf(f, "\n	  %-10d %-10d %-10d %-10d %-10d %-10d",
 			stats->restarts, stats->bus_error,
 			stats->arbitration_lost, stats->error_warning,
 			stats->error_passive, stats->bus_off);
-- 
1.9.2
