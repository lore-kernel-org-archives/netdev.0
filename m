From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH RFC 2/7] cpsw: add missing fields to the CPSW_SS register bank.
Date: Thu, 11 Oct 2012 22:27:17 +0200
Message-ID: <be9290b7284afcc8fe859f4290ef392c247fd191.1349985570.git.richardcochran@gmail.com>
References: <cover.1349985570.git.richardcochran@gmail.com>
Cc: <linux-arm-kernel@lists.infradead.org>,
	David Miller <davem@davemloft.net>,
	Cyril Chemparathy <cyril@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Sriramakrishnan A G <srk@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:47986 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755249Ab2JKU1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 16:27:38 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so1793709wgb.1
        for <netdev@vger.kernel.org>; Thu, 11 Oct 2012 13:27:37 -0700 (PDT)
In-Reply-To: <cover.1349985570.git.richardcochran@gmail.com>
In-Reply-To: <cover.1349985570.git.richardcochran@gmail.com>
References: <cover.1349985570.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/ti/cpsw.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index a996188..24304e8 100644
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
