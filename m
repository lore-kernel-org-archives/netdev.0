From: Aleksander Morgado <aleksander@lanedo.com>
Subject: [PATCH] net: qmi_wwan: fix Cinterion PLXX product ID
Date: Wed, 25 Sep 2013 17:02:36 +0200
Message-ID: <1380121356-28601-1-git-send-email-aleksander@lanedo.com>
Cc: davem@davemloft.net, bjorn@mork.no, dcbw@redhat.com,
	Aleksander Morgado <aleksander@lanedo.com>,
	Hans-Christoph Schemmel <hans-christoph.schemmel@gemalto.com>,
	Christian Schmiedl <christian.schmiedl@gemalto.com>,
	Nicolaus Colberg <nicolaus.colberg@gemalto.com>
To: netdev@vger.kernel.org, linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanedo.com ([85.214.136.179]:57373 "EHLO lanedo.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755947Ab3IYPMy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Sep 2013 11:12:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cinterion PLXX LTE devices have a 0x0060 product ID, not 0x12d1.

The blacklisting in the serial/option driver does actually use the correct PID,
as per commit 8ff10bdb14a52e3f25d4ce09e0582a8684c1a6db ('USB: Blacklisted
Cinterion's PLxx WWAN Interface').

CC: Hans-Christoph Schemmel <hans-christoph.schemmel@gemalto.com>
CC: Christian Schmiedl <christian.schmiedl@gemalto.com>
CC: Nicolaus Colberg <nicolaus.colberg@gemalto.com>
Signed-off-by: Aleksander Morgado <aleksander@lanedo.com>
---
 drivers/net/usb/qmi_wwan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 6312332..3d6aaf7 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -714,7 +714,7 @@ static const struct usb_device_id products[] = {
 	{QMI_FIXED_INTF(0x2357, 0x0201, 4)},	/* TP-LINK HSUPA Modem MA180 */
 	{QMI_FIXED_INTF(0x2357, 0x9000, 4)},	/* TP-LINK MA260 */
 	{QMI_FIXED_INTF(0x1bc7, 0x1200, 5)},	/* Telit LE920 */
-	{QMI_FIXED_INTF(0x1e2d, 0x12d1, 4)},	/* Cinterion PLxx */
+	{QMI_FIXED_INTF(0x1e2d, 0x0060, 4)},	/* Cinterion PLxx */
 
 	/* 4. Gobi 1000 devices */
 	{QMI_GOBI1K_DEVICE(0x05c6, 0x9212)},	/* Acer Gobi Modem Device */
-- 
1.8.3.1
