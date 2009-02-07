From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 26/26] igb: remove dead code in transmit routine
Date: Sat, 07 Feb 2009 01:23:32 -0800
Message-ID: <20090207092332.15697.16033.stgit@lost.foo-projects.org>
References: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.emeryville.ca.mail.comcast.net ([76.96.30.16]:35215 "EHLO
	QMTA01.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751751AbZBGJXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 04:23:52 -0500
In-Reply-To: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 8bc1ffa..f8c2919 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2951,12 +2951,9 @@ static int igb_xmit_frame_ring_adv(struct sk_buff *skb,
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	unsigned int first;
 	unsigned int tx_flags = 0;
-	unsigned int len;
 	u8 hdr_len = 0;
 	int tso = 0;
 
-	len = skb_headlen(skb);
-
 	if (test_bit(__IGB_DOWN, &adapter->state)) {
 		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;

