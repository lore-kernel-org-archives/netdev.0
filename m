From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Subject: [PATCH 6/7] [DCCP]: Shift sysctls into feat.h
Date: Thu, 24 Aug 2006 15:27:35 +1200
Message-ID: <200608241527.35715.ian.mcdonald@jandi.co.nz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.179]:43314 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S1030230AbWHXD1r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 23:27:47 -0400
Received: by py-out-1112.google.com with SMTP id n25so513526pyg
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2006 20:27:46 -0700 (PDT)
To: Andrea Bittau <a.bittau@cs.ucl.ac.uk>,
	David Miller <davem@davemloft.net>,
	Arnaldo de Melo <arnaldo.melo@gmail.com>,
	"DCCP (vger)" <dccp@vger.kernel.org>,
	"netdev, " <netdev@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This shifts further sysctls into feat.h. No change in 
functionality - shifting code only.

Signed off by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/feat.h b/net/dccp/feat.h
index b44c455..cee553d 100644
--- a/net/dccp/feat.h
+++ b/net/dccp/feat.h
@@ -27,5 +27,10 @@ extern int  dccp_feat_clone(struct sock 
 extern int  dccp_feat_init(struct dccp_minisock *dmsk);
 
 extern int  dccp_feat_default_sequence_window;
+extern int  dccp_feat_default_rx_ccid;
+extern int  dccp_feat_default_tx_ccid;
+extern int  dccp_feat_default_ack_ratio;
+extern int  dccp_feat_default_send_ack_vector;
+extern int  dccp_feat_default_send_ndp_count;
 
 #endif /* _DCCP_FEAT_H */
diff --git a/net/dccp/sysctl.c b/net/dccp/sysctl.c
index c1ba945..38bc157 100644
--- a/net/dccp/sysctl.c
+++ b/net/dccp/sysctl.c
@@ -11,18 +11,12 @@
 
 #include <linux/mm.h>
 #include <linux/sysctl.h>
+#include "feat.h"
 
 #ifndef CONFIG_SYSCTL
 #error This file should not be compiled without CONFIG_SYSCTL defined
 #endif
 
-extern int dccp_feat_default_sequence_window;
-extern int dccp_feat_default_rx_ccid;
-extern int dccp_feat_default_tx_ccid;
-extern int dccp_feat_default_ack_ratio;
-extern int dccp_feat_default_send_ack_vector;
-extern int dccp_feat_default_send_ndp_count;
-
 static struct ctl_table dccp_default_table[] = {
 	{
 		.ctl_name	= NET_DCCP_DEFAULT_SEQ_WINDOW,
