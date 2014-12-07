From: roopa@cumulusnetworks.com
Subject: [PATCH net-next v4 1/2] bridge: remove mode 'swdev'
Date: Sun,  7 Dec 2014 09:09:05 -0800
Message-ID: <1417972147-62196-2-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, tgraf@suug.ch, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:57827 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752220AbaLGRJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Dec 2014 12:09:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

swdev mode was introduced to indicate switchdev offloads
for bridging from user space. But user can
use BRIDGE_FLAGS_SELF to directly call into the
hw switch port driver today. swdev mode is not required anymore.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/uapi/linux/if_bridge.h |    1 -
 1 file changed, 1 deletion(-)

diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
index 296a556..da17e45 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -105,7 +105,6 @@ struct __fdb_entry {
 
 #define BRIDGE_MODE_VEB		0	/* Default loopback mode */
 #define BRIDGE_MODE_VEPA	1	/* 802.1Qbg defined VEPA mode */
-#define BRIDGE_MODE_SWDEV	2	/* Full switch device offload */
 
 /* Bridge management nested attributes
  * [IFLA_AF_SPEC] = {
-- 
1.7.10.4
