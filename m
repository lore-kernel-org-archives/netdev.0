From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH net-2.6 1/3] cxgb3: remove call to stop TX queues at load time.
Date: Mon, 01 Nov 2010 13:59:41 -0700
Message-ID: <20101101205940.27716.24553.stgit@speedy5.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dm@chelsio.com, leedom@chelsio.com, swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:30097 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754518Ab0KAVCD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Nov 2010 17:02:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Remove racy queue stopping after device registration.

Signed-off-by: Divy Le Ray <divy@chelsio.com>

---

 drivers/net/cxgb3/cxgb3_main.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)


diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 407d4e2..046d846 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -3341,7 +3341,6 @@ static int __devinit init_one(struct pci_dev *pdev,
 				adapter->name = adapter->port[i]->name;
 
 			__set_bit(i, &adapter->registered_device_map);
-			netif_tx_stop_all_queues(adapter->port[i]);
 		}
 	}
 	if (!adapter->registered_device_map) {

