From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next v2 06/27] cnic: remove use of VLAN_TAG_PRESENT
Date: Tue,  3 Jan 2017 21:52:34 +0100 (CET)
Message-ID: <97b21ef6e60c912060ee025ead3e3c88359a07d1.1483475202.git.mirq-linux@rere.qmqm.pl>
References: <cover.1483475202.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:34710 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935895AbdACUwj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 15:52:39 -0500
In-Reply-To: <cover.1483475202.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
---
 drivers/net/ethernet/broadcom/cnic.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index b1d2ac818710..6e3c61081338 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -5734,7 +5734,7 @@ static int cnic_netdev_event(struct notifier_block *this, unsigned long event,
 		if (realdev) {
 			dev = cnic_from_netdev(realdev);
 			if (dev) {
-				vid |= VLAN_TAG_PRESENT;
+				vid |= VLAN_CFI_MASK;	/* make non-zero */
 				cnic_rcv_netevent(dev->cnic_priv, event, vid);
 				cnic_put(dev);
 			}
-- 
2.11.0
