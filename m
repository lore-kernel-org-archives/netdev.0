From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 04/11] qlge: set maximal number of default RSS
 queues
Date: Sun, 1 Jul 2012 16:18:53 +0300
Message-ID: <1341148740-7375-5-git-send-email-yuvalmin@broadcom.com>
References: <1341148740-7375-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Anirban Chakraborty" <anirban.chakraborty@qlogic.com>,
	"Jitendra Kalsaria" <jitendra.kalsaria@qlogic.com>,
	"Ron Mercer" <ron.mercer@qlogic.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3426 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932354Ab2GANUm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Jul 2012 09:20:42 -0400
In-Reply-To: <1341148740-7375-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Cc: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Cc: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Cc: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index 09d8d33..3c3499d 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -4649,7 +4649,7 @@ static int __devinit qlge_probe(struct pci_dev *pdev,
 	int err = 0;
 
 	ndev = alloc_etherdev_mq(sizeof(struct ql_adapter),
-			min(MAX_CPUS, (int)num_online_cpus()));
+			min(MAX_CPUS, netif_get_num_default_rss_queues()));
 	if (!ndev)
 		return -ENOMEM;
 
-- 
1.7.9.rc2
