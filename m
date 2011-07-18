From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 19/45] bna: HW Type Check Fix
Date: Mon, 18 Jul 2011 01:22:39 -0700
Message-ID: <1310977385-5268-9-git-send-email-rmody@brocade.com>
References: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>, <dradovan@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:37792 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753418Ab1GRIXx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:23:53 -0400
In-Reply-To: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change detils:
 - The macro bfa_ioc_is_cna() will return true  if IOC type is BFA_IOC_TYPE_FCoE
   or BFA_IOC_TYPE_LL

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bfa_ioc.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bna/bfa_ioc.h b/drivers/net/bna/bfa_ioc.h
index bcc9acc..07e1a9d 100644
--- a/drivers/net/bna/bfa_ioc.h
+++ b/drivers/net/bna/bfa_ioc.h
@@ -234,7 +234,8 @@ struct bfa_ioc_hwif {
 #define bfa_ioc_portid(__ioc)		((__ioc)->port_id)
 #define bfa_ioc_asic_gen(__ioc)		((__ioc)->asic_gen)
 #define bfa_ioc_is_cna(__ioc)		\
-	(bfa_nw_ioc_get_type(ioc) == BFA_IOC_TYPE_FCoE)
+	((bfa_nw_ioc_get_type(ioc) == BFA_IOC_TYPE_FCoE) ||	\
+	 (bfa_nw_ioc_get_type(ioc) == BFA_IOC_TYPE_LL))
 #define bfa_ioc_fetch_stats(__ioc, __stats) \
 		(((__stats)->drv_stats) = (__ioc)->stats)
 #define bfa_ioc_clr_stats(__ioc)	\
-- 
1.7.1

