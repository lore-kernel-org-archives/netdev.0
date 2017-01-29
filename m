From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v2 2/3] sh_eth: add missing EESIPR bits
Date: Sun, 29 Jan 2017 15:08:09 +0300
Message-ID: <4195481.pfyme3sVPu@wasted.cogentembedded.com>
References: <3387005.NzsGXf10rT@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f51.google.com ([209.85.215.51]:36219 "EHLO
        mail-lf0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750984AbdA2MIN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 07:08:13 -0500
Received: by mail-lf0-f51.google.com with SMTP id z134so182237518lff.3
        for <netdev@vger.kernel.org>; Sun, 29 Jan 2017 04:08:12 -0800 (PST)
In-Reply-To: <3387005.NzsGXf10rT@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Renesas SH77{34|63} manuals  describe more EESIPR bits than the current
driver. Declare the new bits with the end goal of using the bit names
instead of the bare numbers  for  the 'sh_eth_cpu_data::eesipr_value'
initializers...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Reviewed-by: Geert Uytterhoeven <geert+renesas@glider.be>

---
Changes in version 2:
- added Geert's tag.

 drivers/net/ethernet/renesas/sh_eth.h |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.h
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.h
+++ net-next/drivers/net/ethernet/renesas/sh_eth.h
@@ -269,13 +269,17 @@ enum EESR_BIT {
 
 /* EESIPR */
 enum EESIPR_BIT {
-	EESIPR_TWBIP	= 0x40000000,
+	EESIPR_TWB1IP	= 0x80000000,
+	EESIPR_TWBIP	= 0x40000000,	/* same as TWB0IP */
+	EESIPR_TC1IP	= 0x20000000,
+	EESIPR_TUCIP	= 0x10000000,
+	EESIPR_ROCIP	= 0x08000000,
 	EESIPR_TABTIP	= 0x04000000,
 	EESIPR_RABTIP	= 0x02000000,
 	EESIPR_RFCOFIP	= 0x01000000,
 	EESIPR_ADEIP	= 0x00800000,
 	EESIPR_ECIIP	= 0x00400000,
-	EESIPR_FTCIP	= 0x00200000,
+	EESIPR_FTCIP	= 0x00200000,	/* same as TC0IP */
 	EESIPR_TDEIP	= 0x00100000,
 	EESIPR_TFUFIP	= 0x00080000,
 	EESIPR_FRIP	= 0x00040000,
@@ -286,6 +290,8 @@ enum EESIPR_BIT {
 	EESIPR_CDIP	= 0x00000200,
 	EESIPR_TROIP	= 0x00000100,
 	EESIPR_RMAFIP	= 0x00000080,
+	EESIPR_CEEFIP	= 0x00000040,
+	EESIPR_CELFIP	= 0x00000020,
 	EESIPR_RRFIP	= 0x00000010,
 	EESIPR_RTLFIP	= 0x00000008,
 	EESIPR_RTSFIP	= 0x00000004,
