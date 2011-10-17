From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [PATCH] iproute2: update CAN bitrate SJW help text
Date: Mon, 17 Oct 2011 17:43:37 +0200
Message-ID: <4E9C4D29.7010302@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-can@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:53777 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752452Ab1JQPnn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 11:43:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ip-tool from iproute2 already supports to pass a user defined SJW
value for the in-kernel bittiming calculation. This patch updates the
help text accordingly.

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

---

diff --git a/ip/iplink_can.c b/ip/iplink_can.c
index c8af4bc..00e7d98 100644
--- a/ip/iplink_can.c
+++ b/ip/iplink_can.c
@@ -23,7 +23,8 @@ static void usage(void)
 {
 	fprintf(stderr,
 		"Usage: ip link set DEVICE type can\n"
-	        "\t[ bitrate BITRATE [ sample-point SAMPLE-POINT] ] | \n"
+		"\t[ bitrate BITRATE [ sample-point SAMPLE-POINT ] [ sjw SJW "
+		"] ] | \n"
 	        "\t[ tq TQ prop-seg PROP_SEG phase-seg1 PHASE-SEG1\n "
 		"\t  phase-seg2 PHASE-SEG2 [ sjw SJW ] ]\n"
 		"\n"
