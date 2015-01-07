From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: [PATCH] sh-eth: Set fdr_value of R-Car SoCs
Date: Wed,  7 Jan 2015 14:40:15 +0900
Message-ID: <1420609215-6969-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Cc: yoshihiro.shimoda.uh@renesas.com, linux-sh@vger.kernel.org,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:56216 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751192AbbAGFk0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 00:40:26 -0500
Received: by mail-pd0-f181.google.com with SMTP id v10so2430651pde.12
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 21:40:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FDR register of R-Car set in fdr_value can have the original settings.
This sets the value that is suitable for each SoCs to fdr_value of R8A777x
and R8A779x.

Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
---
 drivers/net/ethernet/renesas/sh_eth.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 59ee457..62f2e88 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -473,6 +473,7 @@ static struct sh_eth_cpu_data r8a777x_data = {
 	.eesr_err_check	= EESR_TWB | EESR_TABT | EESR_RABT | EESR_RFE |
 			  EESR_RDE | EESR_RFRMER | EESR_TFE | EESR_TDE |
 			  EESR_ECI,
+	.fdr_value	= 0x00000f0f,
 
 	.apr		= 1,
 	.mpr		= 1,
@@ -495,6 +496,7 @@ static struct sh_eth_cpu_data r8a779x_data = {
 	.eesr_err_check	= EESR_TWB | EESR_TABT | EESR_RABT | EESR_RFE |
 			  EESR_RDE | EESR_RFRMER | EESR_TFE | EESR_TDE |
 			  EESR_ECI,
+	.fdr_value	= 0x00000f0f,
 
 	.apr		= 1,
 	.mpr		= 1,
-- 
2.1.3
