From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V2 2/7] cpsw: add missing fields to the CPSW_SS register bank.
Date: Mon, 15 Oct 2012 21:48:08 +0200
Message-ID: <3b83888173e2bf997a50a3491ac4e20b00769d95.1350329726.git.richardcochran@gmail.com>
References: <cover.1350329726.git.richardcochran@gmail.com>
Cc: <linux-arm-kernel@lists.infradead.org>,
	David Miller <davem@davemloft.net>,
	Cyril Chemparathy <cyril@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Sriramakrishnan A G <srk@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:46584 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754564Ab2JOTsx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2012 15:48:53 -0400
Received: by mail-wi0-f172.google.com with SMTP id hq12so2563203wib.1
        for <netdev@vger.kernel.org>; Mon, 15 Oct 2012 12:48:52 -0700 (PDT)
In-Reply-To: <cover.1350329726.git.richardcochran@gmail.com>
In-Reply-To: <cover.1350329726.git.richardcochran@gmail.com>
References: <cover.1350329726.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/ti/cpsw.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 3568b46..1bdbb36 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -146,6 +146,14 @@ struct cpsw_ss_regs {
 	u32	soft_reset;
 	u32	stat_port_en;
 	u32	ptype;
+	u32	soft_idle;
+	u32	thru_rate;
+	u32	gap_thresh;
+	u32	tx_start_wds;
+	u32	flow_control;
+	u32	vlan_ltype;
+	u32	ts_ltype;
+	u32	dlr_ltype;
 };
 
 struct cpsw_slave_regs {
-- 
1.7.2.5
