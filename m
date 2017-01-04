From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next] cnic: remove use of VLAN_TAG_PRESENT
Date: Wed,  4 Jan 2017 01:07:58 +0100 (CET)
Message-ID: <7bbf1043674601196c45183038cb4300291920bd.1483487887.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:37236 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759856AbdADAIC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 19:08:02 -0500
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
