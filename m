From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH 15/15] ptp: PTP_1588_CLOCK_PCH depends on x86
Date: Tue,  7 May 2013 16:18:23 +0200
Message-ID: <1367936303-13386-15-git-send-email-jslaby@suse.cz>
References: <1367936303-13386-1-git-send-email-jslaby@suse.cz>
Cc: linux-kernel@vger.kernel.org, Jeff Mahoney <jeffm@suse.com>,
	Jiri Slaby <jslaby@suse.cz>,
	Richard Cochran <richardcochran@gmail.com>,
	netdev@vger.kernel.org
To: jirislaby@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1367936303-13386-1-git-send-email-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Mahoney <jeffm@suse.com>

The PCH EG20T is only compatible with Intel Atom processors so it
should depend on x86.

Signed-off-by: Jeff Mahoney <jeffm@suse.com>
Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Richard Cochran <richardcochran@gmail.com>
Cc: netdev@vger.kernel.org
---
 drivers/ptp/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/ptp/Kconfig b/drivers/ptp/Kconfig
index 1ea6f1d..e02b7d4 100644
--- a/drivers/ptp/Kconfig
+++ b/drivers/ptp/Kconfig
@@ -72,6 +72,7 @@ config DP83640_PHY
 
 config PTP_1588_CLOCK_PCH
 	tristate "Intel PCH EG20T as PTP clock"
+	depends on X86
 	select PTP_1588_CLOCK
 	help
 	  This driver adds support for using the PCH EG20T as a PTP
-- 
1.8.2.1
