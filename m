From: roopa@cumulusnetworks.com
Subject: [PATCH net-next v5 3/3] bridge: remove mode BRIDGE_MODE_SWDEV
Date: Mon,  8 Dec 2014 14:04:21 -0800
Message-ID: <1418076261-24593-4-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, tgraf@suug.ch, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:45257 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751794AbaLHWEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 17:04:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch removes bridge mode swdev.
Users can use BRIDGE_FLAGS_SELF to indicate swdev offload
if needed.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/uapi/linux/if_bridge.h |    1 -
 1 file changed, 1 deletion(-)

diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
index 05f0869..b03ee8f 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -105,7 +105,6 @@ struct __fdb_entry {
 
 #define BRIDGE_MODE_VEB		0	/* Default loopback mode */
 #define BRIDGE_MODE_VEPA	1	/* 802.1Qbg defined VEPA mode */
-#define BRIDGE_MODE_SWDEV	2	/* Full switch device offload */
 #define BRIDGE_MODE_UNDEF	0xFFFF  /* mode undefined */
 
 /* Bridge management nested attributes
-- 
1.7.10.4
