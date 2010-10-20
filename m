From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next-2.6 PATCH 4/5] enic: Change min MTU
Date: Wed, 20 Oct 2010 13:17:14 -0700
Message-ID: <20101020201714.26870.38418.stgit@savbu-pc100.cisco.com>
References: <20101020201609.26870.80308.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roprabhu@cisco.com, dwang2@cisco.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:14969 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755503Ab0JTURO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Oct 2010 16:17:14 -0400
In-Reply-To: <20101020201609.26870.80308.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>

Change min MTU to 68.

Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 drivers/net/enic/enic_res.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)


diff --git a/drivers/net/enic/enic_res.h b/drivers/net/enic/enic_res.h
index 83bd172..9a103d9 100644
--- a/drivers/net/enic/enic_res.h
+++ b/drivers/net/enic/enic_res.h
@@ -30,7 +30,7 @@
 #define ENIC_MIN_RQ_DESCS		64
 #define ENIC_MAX_RQ_DESCS		4096
 
-#define ENIC_MIN_MTU			576  /* minimum for IPv4 */
+#define ENIC_MIN_MTU			68
 #define ENIC_MAX_MTU			9000
 
 #define ENIC_MULTICAST_PERFECT_FILTERS	32

