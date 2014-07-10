From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH v4 4/4] ARM: mvebu: enable Armada 375 network driver in mvebu_v7_defconfig
Date: Thu, 10 Jul 2014 16:52:16 -0300
Message-ID: <1405021936-28658-5-git-send-email-ezequiel.garcia@free-electrons.com>
References: <1405021936-28658-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: David Miller <davem@davemloft.net>,
	Jason Cooper <jason@lakedaemon.net>,
	Marcin Wojtas <mw@semihalf.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>
To: <netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:58538 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751585AbaGJTxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 15:53:34 -0400
In-Reply-To: <1405021936-28658-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcin Wojtas <mw@semihalf.com>

Now that the Armada 375 network driver has been pushed, let's enable it
in mvebu_v7_defconfig.

Signed-off-by: Marcin Wojtas <mw@semihalf.com>
---
 arch/arm/configs/mvebu_v7_defconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arm/configs/mvebu_v7_defconfig b/arch/arm/configs/mvebu_v7_defconfig
index b0bfefa..b477631 100644
--- a/arch/arm/configs/mvebu_v7_defconfig
+++ b/arch/arm/configs/mvebu_v7_defconfig
@@ -46,6 +46,7 @@ CONFIG_AHCI_MVEBU=y
 CONFIG_SATA_MV=y
 CONFIG_NETDEVICES=y
 CONFIG_MVNETA=y
+CONFIG_MVPP2=y
 CONFIG_MARVELL_PHY=y
 CONFIG_MWIFIEX=y
 CONFIG_MWIFIEX_SDIO=y
-- 
1.9.1
