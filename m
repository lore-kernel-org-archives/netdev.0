From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH] if_link: Add PORT_REQUEST_MAX
Date: Wed, 09 Mar 2011 12:34:31 -0800
Message-ID: <20110309203431.21853.21864.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:49326 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751675Ab1CIUec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2011 15:34:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

This patch adds __PORT_REQUEST_MAX to port request enumeration. And defines
PORT_REQUEST_MAX.

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
---
 include/linux/if_link.h |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)


diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index f4a2e6b..b37cc09 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -353,8 +353,11 @@ enum {
 	PORT_REQUEST_PREASSOCIATE_RR,
 	PORT_REQUEST_ASSOCIATE,
 	PORT_REQUEST_DISASSOCIATE,
+	__PORT_REQUEST_MAX,
 };
 
+#define PORT_REQUEST_MAX (__PORT_REQUEST_MAX - 1)
+
 enum {
 	PORT_VDP_RESPONSE_SUCCESS = 0,
 	PORT_VDP_RESPONSE_INVALID_FORMAT,

