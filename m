From: Paul Burton <paul.burton@imgtec.com>
Subject: [PATCH 18/28] ptp: pch: allow build on MIPS platforms
Date: Mon, 30 Nov 2015 16:21:43 +0000
Message-ID: <1448900513-20856-19-git-send-email-paul.burton@imgtec.com>
References: <1448900513-20856-1-git-send-email-paul.burton@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Burton <paul.burton@imgtec.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	Richard Cochran <richardcochran@gmail.com>
To: <linux-mips@linux-mips.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448900513-20856-1-git-send-email-paul.burton@imgtec.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow the ptp_pch driver to be built on MIPS platforms in preparation
for use on the MIPS Boston board.

Signed-off-by: Paul Burton <paul.burton@imgtec.com>
---

 drivers/ptp/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/ptp/Kconfig b/drivers/ptp/Kconfig
index ee3de34..ee43549 100644
--- a/drivers/ptp/Kconfig
+++ b/drivers/ptp/Kconfig
@@ -74,7 +74,7 @@ config DP83640_PHY
 
 config PTP_1588_CLOCK_PCH
 	tristate "Intel PCH EG20T as PTP clock"
-	depends on X86_32 || COMPILE_TEST
+	depends on X86_32 || MIPS || COMPILE_TEST
 	depends on HAS_IOMEM && NET
 	select PTP_1588_CLOCK
 	help
-- 
2.6.2
