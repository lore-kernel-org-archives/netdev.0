From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH net-next V3 3/3] xen: netif.h: document feature-split-event-channels
Date: Wed, 22 May 2013 17:34:47 +0100
Message-ID: <1369240487-18834-4-git-send-email-wei.liu2@citrix.com>
References: <1369240487-18834-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jbeulich@suse.com>, <ian.campbell@citrix.com>,
	<annie.li@oracle.com>, <konrad.wilk@oracle.com>,
	<david.vrabel@citrix.com>, Wei Liu <wei.liu2@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:34299 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755063Ab3EVQeu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 May 2013 12:34:50 -0400
In-Reply-To: <1369240487-18834-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch synchronises documentation for feature-split-event-channels from
Xen canonical header file.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 include/xen/interface/io/netif.h |   12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/include/xen/interface/io/netif.h b/include/xen/interface/io/netif.h
index 3ef3fe0..eb262e3 100644
--- a/include/xen/interface/io/netif.h
+++ b/include/xen/interface/io/netif.h
@@ -38,6 +38,18 @@
  * that it cannot safely queue packets (as it may not be kicked to send them).
  */
 
+ /*
+ * "feature-split-event-channels" is introduced to separate guest TX
+ * and RX notificaion. Backend either doesn't support this feature or
+ * advertise it via xenstore as 0 (disabled) or 1 (enabled).
+ *
+ * To make use of this feature, frontend should allocate two event
+ * channels for TX and RX, advertise them to backend as
+ * "event-channel-tx" and "event-channel-rx" respectively. If frontend
+ * doesn't want to use this feature, it just writes "event-channel"
+ * node as before.
+ */
+
 /*
  * This is the 'wire' format for packets:
  *  Request 1: xen_netif_tx_request  -- XEN_NETTXF_* (any flags)
-- 
1.7.10.4
