From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 3/3] netvsc: use typed pointer for internal state
Date: Mon, 29 May 2017 11:31:59 -0700
Message-ID: <20170529183159.22205-3-sthemmin@microsoft.com>
References: <20170529183159.22205-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33222 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751080AbdE2ScH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 May 2017 14:32:07 -0400
Received: by mail-pf0-f169.google.com with SMTP id e193so51302585pfh.0
        for <netdev@vger.kernel.org>; Mon, 29 May 2017 11:32:06 -0700 (PDT)
In-Reply-To: <20170529183159.22205-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The element netvsc_device:extension is always a pointer to RNDIS
information.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 262b2ea576a3..f82d54e0208c 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -763,8 +763,7 @@ struct netvsc_device {
 
 	refcount_t sc_offered;
 
-	/* Holds rndis device info */
-	void *extension;
+	struct rndis_device *extension;
 
 	int ring_size;
 
-- 
2.11.0
