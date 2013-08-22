From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 12/15] e1000e: cleanup whitespace in recent commit
Date: Thu, 22 Aug 2013 02:49:48 -0700
Message-ID: <1377164991-27988-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1377164991-27988-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:25110 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752855Ab3HVJuF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Aug 2013 05:50:05 -0400
In-Reply-To: <1377164991-27988-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Commit (c96ddb0b e1000e: Use marco instead of digit for defining
e1000_rx_desc_packet_split) moved a define from one file to another but
missed using proper indentation/whitespace.

v2:
 - Fixed patch description based on feedback from Sergei Shtylyov

CC: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
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
