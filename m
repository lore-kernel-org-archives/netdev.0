From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [PATCH 1/2] net, rps: fix the comment of net_rps_action_and_irq_enable()
Date: Wed,  1 Jan 2014 04:34:50 +0800
Message-ID: <1388522091-17536-1-git-send-email-zwu.kernel@gmail.com>
Cc: davem@davemloft.net, Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:54430 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756521Ab3LaUfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 15:35:05 -0500
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <zwu.kernel@gmail.com>;
	Tue, 31 Dec 2013 13:35:05 -0700
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id B8AA719D8042
	for <netdev@vger.kernel.org>; Tue, 31 Dec 2013 13:34:54 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp08025.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBVKZ2qP3080682
	for <netdev@vger.kernel.org>; Tue, 31 Dec 2013 21:35:02 +0100
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBVKZ2Ej012668
	for <netdev@vger.kernel.org>; Tue, 31 Dec 2013 13:35:02 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
---
 net/core/dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 973c236..cc9ab80 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4030,7 +4030,7 @@ gro_result_t napi_gro_frags(struct napi_struct *napi)
 EXPORT_SYMBOL(napi_gro_frags);
 
 /*
- * net_rps_action sends any pending IPI's for rps.
+ * net_rps_action_and_irq_enable sends any pending IPI's for rps.
  * Note: called with local irq disabled, but exits with local irq enabled.
  */
 static void net_rps_action_and_irq_enable(struct softnet_data *sd)
-- 
1.7.6.5
