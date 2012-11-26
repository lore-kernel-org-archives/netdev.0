From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next] cpts: add missing kconfig dependency
Date: Mon, 26 Nov 2012 13:07:18 +0100
Message-ID: <1353931638-1023-1-git-send-email-richardcochran@gmail.com>
Cc: <linux-arm-kernel@lists.infradead.org>,
	David Miller <davem@davemloft.net>,
	Cyril Chemparathy <cyril@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:61291 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752712Ab2KZMHb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 07:07:31 -0500
Received: by mail-ea0-f174.google.com with SMTP id e13so4367681eaa.19
        for <netdev@vger.kernel.org>; Mon, 26 Nov 2012 04:07:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Common Platform Time Sync function of the CPSW does not depend the
CPSW configuration option as it should. This patch fixes the issue by
adding the dependency.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/ti/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kconfig
index 48fcb5e..4426151 100644
--- a/drivers/net/ethernet/ti/Kconfig
+++ b/drivers/net/ethernet/ti/Kconfig
@@ -62,6 +62,7 @@ config TI_CPSW
 
 config TI_CPTS
 	boolean "TI Common Platform Time Sync (CPTS) Support"
+	depends on TI_CPSW
 	select PTP_1588_CLOCK
 	---help---
 	  This driver supports the Common Platform Time Sync unit of
-- 
1.7.2.5
