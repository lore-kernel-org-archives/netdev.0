From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 4/6] nfp: remove unused suspicious mask defines
Date: Sat, 16 Apr 2016 11:25:52 +0100
Message-ID: <1460802354-14248-5-git-send-email-jakub.kicinski@netronome.com>
References: <1460802354-14248-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:34225 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751263AbcDPK0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2016 06:26:24 -0400
Received: by mail-wm0-f54.google.com with SMTP id l6so13414768wml.1
        for <netdev@vger.kernel.org>; Sat, 16 Apr 2016 03:26:23 -0700 (PDT)
In-Reply-To: <1460802354-14248-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NFP_NET_RXR_MASK sounds like a mask which could be used on
NFP_NET_CFG_RXRS_ENABLE register but its value is quite
strange.  In fact there are no users of this define so let's
just remove it.  Same for TX rings.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h b/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
index 3ec950555892..ad6c4e31cedd 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
@@ -81,14 +81,10 @@
 
 /**
  * @NFP_NET_TXR_MAX:         Maximum number of TX rings
- * @NFP_NET_TXR_MASK:        Mask for TX rings
  * @NFP_NET_RXR_MAX:         Maximum number of RX rings
- * @NFP_NET_RXR_MASK:        Mask for RX rings
  */
 #define NFP_NET_TXR_MAX                 64
-#define NFP_NET_TXR_MASK                (NFP_NET_TXR_MAX - 1)
 #define NFP_NET_RXR_MAX                 64
-#define NFP_NET_RXR_MASK                (NFP_NET_RXR_MAX - 1)
 
 /**
  * Read/Write config words (0x0000 - 0x002c)
-- 
1.9.1
