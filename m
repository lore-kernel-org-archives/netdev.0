From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH net-next v2 1/6] fjes: optimize timeout value
Date: Fri, 15 Apr 2016 11:25:21 +0900
Message-ID: <1460687121-26581-1-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1460686800-26427-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: jiri@resnulli.us, isimatu.yasuaki@jp.fujitsu.com,
	Taku Izumi <izumi.taku@jp.fujitsu.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm04.jp.fujitsu.com ([202.219.69.171]:52447 "EHLO
	mgwkm04.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751248AbcDOCdx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 22:33:53 -0400
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by kw-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id ECC8CAC0252
	for <netdev@vger.kernel.org>; Fri, 15 Apr 2016 11:33:45 +0900 (JST)
In-Reply-To: <1460686800-26427-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch optimizes the following timeout value.
 - FJES_DEVICE_RESET_TIMEOUT
 - FJES_COMMAND_REQ_TIMEOUT
 - FJES_COMMAND_REQ_BUFF_TIMEOUT

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/fjes_hw.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/fjes/fjes_hw.h b/drivers/net/fjes/fjes_hw.h
index 6d57b89..baee7f5 100644
--- a/drivers/net/fjes/fjes_hw.h
+++ b/drivers/net/fjes/fjes_hw.h
@@ -33,9 +33,9 @@ struct fjes_hw;
 #define EP_BUFFER_SUPPORT_VLAN_MAX 4
 #define EP_BUFFER_INFO_SIZE 4096
 
-#define FJES_DEVICE_RESET_TIMEOUT  ((17 + 1) * 3) /* sec */
-#define FJES_COMMAND_REQ_TIMEOUT  (5 + 1) /* sec */
-#define FJES_COMMAND_REQ_BUFF_TIMEOUT	(8 * 3) /* sec */
+#define FJES_DEVICE_RESET_TIMEOUT  ((17 + 1) * 3 * 8) /* sec */
+#define FJES_COMMAND_REQ_TIMEOUT  ((5 + 1) * 3 * 8) /* sec */
+#define FJES_COMMAND_REQ_BUFF_TIMEOUT	(60 * 3) /* sec */
 #define FJES_COMMAND_EPSTOP_WAIT_TIMEOUT	(1) /* sec */
 
 #define FJES_CMD_REQ_ERR_INFO_PARAM  (0x0001)
-- 
2.4.3
