From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH 2/2] bgmac: allow enabling on ARCH_BCM_5301X
Date: Fri, 20 Mar 2015 23:14:32 +0100
Message-ID: <1426889672-4969-2-git-send-email-zajec5@gmail.com>
References: <1426889672-4969-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hauke Mehrtens <hauke@hauke-m.de>,
	=?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:35457 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751372AbbCTWOs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 18:14:48 -0400
Received: by webcq43 with SMTP id cq43so92282885web.2
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 15:14:47 -0700 (PDT)
In-Reply-To: <1426889672-4969-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Home routers based on ARM SoCs like BCM4708 also have bcma bus with cor=
e
supported by bgmac.

Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
 drivers/net/ethernet/broadcom/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/Kconfig b/drivers/net/ethern=
et/broadcom/Kconfig
index ee4fdfe..a6f9142 100644
--- a/drivers/net/ethernet/broadcom/Kconfig
+++ b/drivers/net/ethernet/broadcom/Kconfig
@@ -142,7 +142,7 @@ config BNX2X_SRIOV
=20
 config BGMAC
 	tristate "BCMA bus GBit core support"
-	depends on BCMA_HOST_SOC && HAS_DMA && BCM47XX
+	depends on BCMA_HOST_SOC && HAS_DMA && (BCM47XX || ARCH_BCM_5301X)
 	select PHYLIB
 	---help---
 	  This driver supports GBit MAC and BCM4706 GBit MAC cores on BCMA bu=
s.
--=20
1.8.4.5
