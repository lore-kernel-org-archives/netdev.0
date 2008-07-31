From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 2/5] qla3xxx: fix: Fix IFF_MULTICAST setting.
Date: Thu, 31 Jul 2008 13:46:05 -0700
Message-ID: <12175371682233-git-send-email-ron.mercer@qlogic.com>
References: <20080731204514.GA5457@susedev.qlogic.org>
Cc: netdev@vger.kernel.org, Ron Mercer <ron.mercer@qlogic.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:23911 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754253AbYGaUqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 16:46:10 -0400
In-Reply-To: <20080731204514.GA5457@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver was erroneously clearing this bit though the hardware supports multicast.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qla3xxx.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 7ddb2b0..155eb52 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -4036,9 +4036,6 @@ static int __devinit ql3xxx_probe(struct pci_dev *pdev,
 
 	ndev->tx_queue_len = NUM_REQ_Q_ENTRIES;
 
-	/* Turn off support for multicasting */
-	ndev->flags &= ~IFF_MULTICAST;
-
 	/* Record PCI bus information. */
 	ql_get_board_info(qdev);
 
-- 
1.5.0.rc4.16.g9e258

