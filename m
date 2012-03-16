From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH net-next] ethtool: Added a field fw dump_state
Date: Fri, 16 Mar 2012 10:58:30 -0700
Message-ID: <1331920711-16049-1-git-send-email-anirban.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Manish chopra <manish.chopra@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe002.messaging.microsoft.com ([216.32.181.182]:35267
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753795Ab2CPSMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2012 14:12:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish chopra <manish.chopra@qlogic.com>

This field is added to enable/disable firmware dump.

Signed-off-by: Manish chopra <manish.chopra@qlogic.com>
Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 include/linux/ethtool.h |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index e1d9e0e..6ebc7de 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -666,15 +666,22 @@ struct ethtool_flash {
  * 	 %ETHTOOL_GET_DUMP_DATA and this is returned as dump length by driver
  * 	 for %ETHTOOL_GET_DUMP_FLAG command
  * @data: data collected for get dump data operation
+ * @dump_state: state of the firmware dump. which can be enable/disable.
  */
+
+#define ETH_FW_DUMP_ENABLE	1
+#define ETH_FW_DUMP_DISABLE	0
+
 struct ethtool_dump {
 	__u32	cmd;
 	__u32	version;
 	__u32	flag;
 	__u32	len;
 	__u8	data[0];
+	__u8	dump_state;
 };
 
+
 /* for returning and changing feature sets */
 
 /**
-- 
1.7.1
