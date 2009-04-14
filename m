From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] e1000/e1000: fix compile warning
Date: Tue, 14 Apr 2009 07:42:49 -0700
Message-ID: <20090414144249.9091.15839.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.westchester.pa.mail.comcast.net ([76.96.62.16]:44652
	"EHLO QMTA01.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752123AbZDNXL3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 19:11:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

e1000/e1000e compile report a possible unused variable, fix
that for now.  Shortly after this a small refactor and bug
fix will follow in the same code.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_main.c |    2 +-
 drivers/net/e1000e/netdev.c    |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index ddc5c53..4cd8b25 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3834,7 +3834,7 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 	struct e1000_buffer *buffer_info;
 	unsigned int i, eop;
 	unsigned int count = 0;
-	bool cleaned;
+	bool cleaned = false;
 	unsigned int total_tx_bytes=0, total_tx_packets=0;
 
 	i = tx_ring->next_to_clean;
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 409b58c..3b0f087 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -621,7 +621,7 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter)
 	struct e1000_buffer *buffer_info;
 	unsigned int i, eop;
 	unsigned int count = 0;
-	bool cleaned;
+	bool cleaned = false;
 	unsigned int total_tx_bytes = 0, total_tx_packets = 0;
 
 	i = tx_ring->next_to_clean;

