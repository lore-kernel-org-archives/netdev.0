From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 1/2] SH7619: fix typo in Ether platform data
Date: Thu, 22 Aug 2013 02:17:25 +0400
Message-ID: <201308220217.26081.sergei.shtylyov@cogentembedded.com>
References: <201308220215.16463.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lethal@linux-sh.org,
	linux-sh@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:43240 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752867Ab3HUWRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 18:17:20 -0400
Received: by mail-lb0-f169.google.com with SMTP id u10so1120956lbi.28
        for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 15:17:19 -0700 (PDT)
In-Reply-To: <201308220215.16463.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 06a64f91da72cb5827e2bedef2ead60a123fd66e (SH7619: fix Ether support)  has
a typo in the 'phy_interface' field name of the platform data which causes build
error -- fix it. 

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 arch/sh/kernel/cpu/sh2/setup-sh7619.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: net-next/arch/sh/kernel/cpu/sh2/setup-sh7619.c
===================================================================
--- net-next.orig/arch/sh/kernel/cpu/sh2/setup-sh7619.c
+++ net-next/arch/sh/kernel/cpu/sh2/setup-sh7619.c
@@ -114,7 +114,7 @@ static struct platform_device scif2_devi
 static struct sh_eth_plat_data eth_platform_data = {
 	.phy		= 1,
 	.edmac_endian	= EDMAC_LITTLE_ENDIAN,
-	.phy_interace	= PHY_INTERFACE_MODE_MII,
+	.phy_interface	= PHY_INTERFACE_MODE_MII,
 };
 
 static struct resource eth_resources[] = {
