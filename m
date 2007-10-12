From: Li Yang <leoli@freescale.com>
Subject: [PATCH] gianfar: Cleanup compile warning caused by 0795af57
Date: Fri, 12 Oct 2007 21:53:53 +0800
Message-ID: <1192197233-24958-3-git-send-email-leoli@freescale.com>
References: <1192197233-24958-1-git-send-email-leoli@freescale.com>
 <1192197233-24958-2-git-send-email-leoli@freescale.com>
Cc: Li Yang <leoli@freescale.com>
To: jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:49880 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755926AbXJLNne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 09:43:34 -0400
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by de01egw02.freescale.net (8.12.11/de01egw02) with ESMTP id l9CDhWkw015993
	for <netdev@vger.kernel.org>; Fri, 12 Oct 2007 06:43:32 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id l9CDhPSd011003
	for <netdev@vger.kernel.org>; Fri, 12 Oct 2007 08:43:31 -0500 (CDT)
In-Reply-To: <1192197233-24958-2-git-send-email-leoli@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Li Yang <leoli@freescale.com>
---
 drivers/net/gianfar.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 6d1456a..c15fb1f 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -168,7 +168,6 @@ static int gfar_probe(struct platform_device *pdev)
 	struct gfar_private *priv = NULL;
 	struct gianfar_platform_data *einfo;
 	struct resource *r;
-	int idx;
 	int err = 0;
 	DECLARE_MAC_BUF(mac);
 
-- 
1.5.3.2.104.g41ef

