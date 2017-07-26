From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/14] i40evf: add some missing includes
Date: Wed, 26 Jul 2017 03:31:19 -0700
Message-ID: <20170726103123.76743-11-jeffrey.t.kirsher@intel.com>
References: <20170726103123.76743-1-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:42590 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751565AbdGZKf0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 06:35:26 -0400
In-Reply-To: <20170726103123.76743-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

These includes were all being used in the driver, but weren't
being directly included.

Since the current advised method is to directly include anything
that you need, this implements that.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf.h | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf.h b/drivers/net/ethernet/intel/i40evf/i40evf.h
index 6cc92089fecb..7901cc85cbe5 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf.h
+++ b/drivers/net/ethernet/intel/i40evf/i40evf.h
@@ -39,6 +39,17 @@
 #include <linux/tcp.h>
 #include <linux/sctp.h>
 #include <linux/ipv6.h>
+#include <linux/kernel.h>
+#include <linux/bitops.h>
+#include <linux/timer.h>
+#include <linux/workqueue.h>
+#include <linux/delay.h>
+#include <linux/gfp.h>
+#include <linux/skbuff.h>
+#include <linux/dma-mapping.h>
+#include <linux/etherdevice.h>
+#include <linux/socket.h>
+#include <linux/jiffies.h>
 #include <net/ip6_checksum.h>
 #include <net/udp.h>
 
-- 
2.13.3
