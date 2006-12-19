From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 4/5] qla3xxx: Remove NETIF_F_LLTX from driver features.
Date: Tue, 19 Dec 2006 10:22:38 -0800
Message-ID: <11665525601338-git-send-email-ron.mercer@qlogic.com>
References: <20061219181855.GA8179@linux-7mw0.qlogic.org>
Cc: ron.mercer@qlogic.com, benjamin.li@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:53404 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932884AbWLSSdF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Dec 2006 13:33:05 -0500
To: netdev@vger.kernel.org
In-Reply-To: <20061219181855.GA8179@linux-7mw0.qlogic.org>
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

