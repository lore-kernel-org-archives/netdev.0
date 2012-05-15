From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH NEXT 1/2] linux/ethtool: Added macro ETH_FW_DUMP_DISABLE
Date: Tue, 15 May 2012 07:13:38 -0400
Message-ID: <1337080419-31786-2-git-send-email-manish.chopra@qlogic.com>
References: <1337080419-31786-1-git-send-email-manish.chopra@qlogic.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Manish chopra <manish.chopra@qlogic.com>
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:53457 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1757825Ab2EOLh2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 May 2012 07:37:28 -0400
In-Reply-To: <1337080419-31786-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish chopra <manish.chopra@qlogic.com>

o flag field of ethtool_dump structure must be initialized by this macro
value that is zero, if the firmware dump is disabled.
by this we can get the firmware dump capability [enable/disable] via ethtool

Signed-off-by: Manish chopra <manish.chopra@qlogic.com>
---
 include/linux/ethtool.h |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 89d68d8..fea2ac0 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -661,12 +661,17 @@ struct ethtool_flash {
  * 	%ETHTOOL_SET_DUMP
  * @version: FW version of the dump, filled in by driver
  * @flag: driver dependent flag for dump setting, filled in by driver during
- * 	  get and filled in by ethtool for set operation
+ *        get and filled in by ethtool for set operation.
+ *        flag must be initialized by macro ETH_FW_DUMP_DISABLE value when
+ *        firmware dump is disabled.
  * @len: length of dump data, used as the length of the user buffer on entry to
  * 	 %ETHTOOL_GET_DUMP_DATA and this is returned as dump length by driver
  * 	 for %ETHTOOL_GET_DUMP_FLAG command
  * @data: data collected for get dump data operation
  */
+
+#define ETH_FW_DUMP_DISABLE 0
+
 struct ethtool_dump {
 	__u32	cmd;
 	__u32	version;
-- 
1.7.1
