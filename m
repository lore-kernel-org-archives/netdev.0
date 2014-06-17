From: Jean Delvare <jdelvare@suse.de>
Subject: [PATCH] ptp: ptp_pch depends on x86_32
Date: Tue, 17 Jun 2014 11:59:20 +0200
Message-ID: <20140617115920.677401c3@endymion.delvare>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:47210 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754183AbaFQJ7X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2014 05:59:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ptp_pch driver is for a companion chip to the Intel Atom E600
series processors. These are 32-bit x86 processors so the driver is
only needed on X86_32.

Signed-off-by: Jean Delvare <jdelvare@suse.de>
Cc: Richard Cochran <richardcochran@gmail.com>
---
 drivers/ptp/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-3.15-rc7.orig/drivers/ptp/Kconfig	2014-05-26 09:25:02.623946321 +0200
+++ linux-3.15-rc7/drivers/ptp/Kconfig	2014-05-26 09:26:52.472302884 +0200
@@ -74,7 +74,7 @@ config DP83640_PHY
 
 config PTP_1588_CLOCK_PCH
 	tristate "Intel PCH EG20T as PTP clock"
-	depends on X86 || COMPILE_TEST
+	depends on X86_32 || COMPILE_TEST
 	depends on HAS_IOMEM && NET
 	select PTP_1588_CLOCK
 	help


-- 
Jean Delvare
SUSE L3 Support
