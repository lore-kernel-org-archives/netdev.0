From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 2/3] qla3xxx: Remove NETIF_F_LLTX from driver features.
Date: Mon, 11 Dec 2006 14:29:17 -0800
Message-ID: <1165876158664-git-send-email-ron.mercer@qlogic.com>
Cc: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:47612 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937683AbWLKW3S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Dec 2006 17:29:18 -0500
To: netdev@vger.kernel.org
In-Reply-To: 20061209214706.GA15946@linux-7mw0.qlogic.org
References: 20061209214706.GA15946@linux-7mw0.qlogic.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The TX locking was removed some time ago but this flag was overlooked.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qla3xxx.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 5aef8aa..24205c6 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -3630,7 +3630,6 @@ static int __devinit ql3xxx_probe(struct
 
 	qdev->msg_enable = netif_msg_init(debug, default_msg);
 
-	ndev->features |= NETIF_F_LLTX;
 	if (pci_using_dac)
 		ndev->features |= NETIF_F_HIGHDMA;
 	if (qdev->device_id == QL3032_DEVICE_ID)
-- 
1.4.2.rc2-dirty

