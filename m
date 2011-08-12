From: Robin Holt <holt@sgi.com>
Subject: [PATCH v12 6/6] powerpc: Add flexcan device support for p1010rdb.
Date: Fri, 12 Aug 2011 03:45:52 -0500
Message-ID: <1313138752-24006-7-git-send-email-holt@sgi.com>
References: <1313138752-24006-1-git-send-email-holt@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Marc Kleine-Budde <mkl@pengutronix.de>,
	Wolfgang Grandegger <wg@grandegger.com>,
	U Bhaskar-B22300 <B22300@freescale.com>,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	PPC list <linuxppc-dev@lists.ozlabs.org>,
	Kumar Gala <galak@kernel.crashing.org>
To: Robin Holt <holt@sgi.com>, Kumar Gala <galak@kernel.crashing.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	U Bhaskar-B22300 <B22300@freescale.
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.179.30]:53075 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752626Ab1HLIqh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2011 04:46:37 -0400
In-Reply-To: <1313138752-24006-1-git-send-email-holt@sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow the p1010 processor to select the flexcan network driver.

Signed-off-by: Robin Holt <holt@sgi.com>
Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>,
Acked-by: Wolfgang Grandegger <wg@grandegger.com>,
Cc: U Bhaskar-B22300 <B22300@freescale.com>
Cc: socketcan-core@lists.berlios.de,
Cc: netdev@vger.kernel.org,
Cc: PPC list <linuxppc-dev@lists.ozlabs.org>
Cc: Kumar Gala <galak@kernel.crashing.org>
---
 arch/powerpc/Kconfig |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 6926b61..47682b6 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -656,6 +656,8 @@ config SBUS
 
 config FSL_SOC
 	bool
+	select HAVE_CAN_FLEXCAN if NET && CAN
+	select PPC_CLOCK if CAN_FLEXCAN
 
 config FSL_PCI
  	bool
-- 
1.7.2.1

