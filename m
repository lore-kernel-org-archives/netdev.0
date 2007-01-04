From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 1/3] qla3xxx: Remove NETIF_F_LLTX from driver features.
Date: Wed,  3 Jan 2007 16:33:34 -0800
Message-ID: <11678708162800-git-send-email-ron.mercer@qlogic.com>
References: '<20070104002503.GB22318@linux-7mw0.qlogic.org>'
Cc: ron.mercer@qlogic.com, romieu@fr.zoreil.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:46677 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932212AbXADAdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jan 2007 19:33:37 -0500
To: jeff@garzik.org
In-Reply-To: '<20070104002503.GB22318@linux-7mw0.qlogic.org>'
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Driver TX locking was removed some time ago, but the flag was overlooked.
Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qla3xxx.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index d79d141..36e0830 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -3370,7 +3370,6 @@ static int __devinit ql3xxx_probe(struct
 	SET_MODULE_OWNER(ndev);
 	SET_NETDEV_DEV(ndev, &pdev->dev);
 
-	ndev->features = NETIF_F_LLTX;
 	if (pci_using_dac)
 		ndev->features |= NETIF_F_HIGHDMA;
 
-- 
1.4.2.rc2-dirty

