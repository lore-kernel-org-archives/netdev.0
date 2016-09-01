From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next] r8152: fix the coding style with checkpatch.pl
Date: Thu, 1 Sep 2016 17:01:42 +0800
Message-ID: <1394712342-15778-214-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>, <mario_limonciello@dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([211.75.126.72]:39994 "EHLO
        rtits2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751004AbcIAJYY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 05:24:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

check the coding style with checkpatch.pl and fix the warnings and errors.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index f41a8ad..8915848 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1076,8 +1076,7 @@ static int vendor_mac_passthru_addr_read(struct r8152 *tp, struct sockaddr *sa)
 		return -ENODEV;
 	if (obj->type != ACPI_TYPE_BUFFER || obj->string.length != 0x17) {
 		netif_warn(tp, probe, tp->netdev,
-			   "Invalid buffer when reading pass-thru MAC addr: "
-			   "(%d, %d)\n",
+			   "Invalid buffer for pass-thru MAC addr: (%d, %d)\n",
 			   obj->type, obj->string.length);
 		goto amacout;
 	}
@@ -1090,8 +1089,8 @@ static int vendor_mac_passthru_addr_read(struct r8152 *tp, struct sockaddr *sa)
 	ret = hex2bin(buf, obj->string.pointer + 9, 6);
 	if (!(ret == 0 && is_valid_ether_addr(buf))) {
 		netif_warn(tp, probe, tp->netdev,
-			   "Invalid MAC when reading pass-thru MAC addr: "
-			   "%d, %pM\n", ret, buf);
+			   "Invalid MAC for pass-thru MAC addr: %d, %pM\n",
+			   ret, buf);
 		ret = -EINVAL;
 		goto amacout;
 	}
@@ -1111,9 +1110,9 @@ static int set_ethernet_addr(struct r8152 *tp)
 	struct sockaddr sa;
 	int ret;
 
-	if (tp->version == RTL_VER_01)
+	if (tp->version == RTL_VER_01) {
 		ret = pla_ocp_read(tp, PLA_IDR, 8, sa.sa_data);
-	else {
+	} else {
 		/* if this is not an RTL8153-AD, no eFuse mac pass thru set,
 		 * or system doesn't provide valid _SB.AMAC this will be
 		 * be expected to non-zero
-- 
2.7.4
