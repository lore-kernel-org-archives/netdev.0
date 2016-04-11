From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH net-next 06/11] fjes: optimize timeout value
Date: Mon, 11 Apr 2016 17:10:29 +0900
Message-ID: <1460362229-15251-1-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1460362136-14968-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: Taku Izumi <izumi.taku@jp.fujitsu.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwym03.jp.fujitsu.com ([211.128.242.42]:38632 "EHLO
	mgwym03.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752780AbcDKIS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 04:18:58 -0400
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by yt-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id 7ED94AC00EE
	for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 17:18:45 +0900 (JST)
In-Reply-To: <1460362136-14968-1-git-send-email-izumi.taku@jp.fujitsu.com>
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
index 41fe418..a1c3d65 100644
--- a/drivers/net/fjes/fjes_hw.h
+++ b/drivers/net/fjes/fjes_hw.h
@@ -34,9 +34,9 @@ struct fjes_hw;
 #define EP_BUFFER_INFO_SIZE 4096
 #define EP_TRACE_PAGE_SIZE 4096
 
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
