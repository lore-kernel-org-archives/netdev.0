From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/2] ethtool: Add Direct Attach support to
	connector port reporting
Date: Wed, 25 Nov 2009 02:11:30 -0800
Message-ID: <20091125101128.24430.89112.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net, jeff@garzik.org, shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.westchester.pa.mail.comcast.net ([76.96.59.212]:43349
	"EHLO QMTA14.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758492AbZKYKLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 05:11:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

This patch allows a base driver to specify Direct Attach as the
type of port through the ethtool interface.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 include/linux/ethtool.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index edd03b7..bcaa0e0 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -631,6 +631,8 @@ struct ethtool_ops {
 #define PORT_MII		0x02
 #define PORT_FIBRE		0x03
 #define PORT_BNC		0x04
+#define PORT_DA			0x05
+#define PORT_NONE		0xef
 #define PORT_OTHER		0xff
 
 /* Which transceiver to use. */

