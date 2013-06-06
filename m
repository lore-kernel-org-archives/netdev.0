From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v5 2/8] sh_eth: use EDSR_ENALL to set EDSR
Date: Thu, 6 Jun 2013 23:44:27 +0400
Message-ID: <201306062344.28234.sergei.shtylyov@cogentembedded.com>
References: <201306062339.21353.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:60573 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753212Ab3FFToX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jun 2013 15:44:23 -0400
Received: by mail-lb0-f182.google.com with SMTP id r11so2368652lbv.41
        for <netdev@vger.kernel.org>; Thu, 06 Jun 2013 12:44:22 -0700 (PDT)
In-Reply-To: <201306062339.21353.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>

Use now always available EDSR_ENALL instead of the bare number to set EDSR.

Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
[Sergei: added the changelog, reworded the subject, changing the prefix.]
Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
Changes in version 4:
- added the changelog;
- reworded the subject, changing the prefix.

 drivers/net/ethernet/renesas/sh_eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -523,7 +523,7 @@ static int sh_eth_reset(struct net_devic
 	int ret = 0;
 
 	if (sh_eth_is_gether(mdp)) {
-		sh_eth_write(ndev, 0x03, EDSR);
+		sh_eth_write(ndev, EDSR_ENALL, EDSR);
 		sh_eth_write(ndev, sh_eth_read(ndev, EDMR) | EDMR_SRST_GETHER,
 				EDMR);
 
