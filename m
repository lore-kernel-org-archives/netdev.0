From: Paul Burton <paul.burton@imgtec.com>
Subject: [PATCH v2 1/6] net: pch_gbe: Allow build on MIPS platforms
Date: Wed, 3 Feb 2016 12:02:39 +0000
Message-ID: <1454500964-6256-2-git-send-email-paul.burton@imgtec.com>
References: <1454500964-6256-1-git-send-email-paul.burton@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Burton <paul.burton@imgtec.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: <linux-mips@linux-mips.org>, Ralf Baechle <ralf@linux-mips.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454500964-6256-1-git-send-email-paul.burton@imgtec.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow the pch_gbe driver to be built on MIPS platforms, in preparation
for its use on the MIPS Boston board.

Signed-off-by: Paul Burton <paul.burton@imgtec.com>
---

Changes in v2: None

 drivers/net/ethernet/oki-semi/pch_gbe/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
index 5f7a352..4d3809a 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
@@ -4,7 +4,7 @@
 
 config PCH_GBE
 	tristate "OKI SEMICONDUCTOR IOH(ML7223/ML7831) GbE"
-	depends on PCI && (X86_32 || COMPILE_TEST)
+	depends on PCI && (X86_32 || MIPS || COMPILE_TEST)
 	select MII
 	select PTP_1588_CLOCK_PCH
 	select NET_PTP_CLASSIFY
-- 
2.7.0
