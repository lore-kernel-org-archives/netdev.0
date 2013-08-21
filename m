From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next  12/15] e1000e: cleanup whitespace in recent commit
Date: Wed, 21 Aug 2013 01:23:33 -0700
Message-ID: <1377073416-7872-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1377073416-7872-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:29745 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751981Ab3HUIXx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Aug 2013 04:23:53 -0400
In-Reply-To: <1377073416-7872-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Commit c96ddb0b moved a define from one file to another but missed using
proper indentation/whitespace.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/hw.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/hw.h b/drivers/net/ethernet/intel/e1000e/hw.h
index b799fd9..b7f3843 100644
--- a/drivers/net/ethernet/intel/e1000e/hw.h
+++ b/drivers/net/ethernet/intel/e1000e/hw.h
@@ -233,7 +233,8 @@ union e1000_rx_desc_extended {
 #define MAX_PS_BUFFERS 4
 
 /* Number of packet split data buffers (not including the header buffer) */
-#define PS_PAGE_BUFFERS			(MAX_PS_BUFFERS - 1)
+#define PS_PAGE_BUFFERS	(MAX_PS_BUFFERS - 1)
+
 /* Receive Descriptor - Packet Split */
 union e1000_rx_desc_packet_split {
 	struct {
-- 
1.8.3.1
