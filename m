From: roopa@cumulusnetworks.com
Subject: [PATCH net-next v5 1/3] bridge: new mode flag to indicate mode 'undefined'
Date: Mon,  8 Dec 2014 14:04:19 -0800
Message-ID: <1418076261-24593-2-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, tgraf@suug.ch, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:45219 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751794AbaLHWE0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 17:04:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds mode BRIDGE_MODE_UNDEF for cases where mode is not needed.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

---
 include/uapi/linux/if_bridge.h |    1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
index 296a556..05f0869 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -106,6 +106,7 @@ struct __fdb_entry {
 #define BRIDGE_MODE_VEB		0	/* Default loopback mode */
 #define BRIDGE_MODE_VEPA	1	/* 802.1Qbg defined VEPA mode */
 #define BRIDGE_MODE_SWDEV	2	/* Full switch device offload */
+#define BRIDGE_MODE_UNDEF	0xFFFF  /* mode undefined */
 
 /* Bridge management nested attributes
  * [IFLA_AF_SPEC] = {
-- 
1.7.10.4
