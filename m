From: Zhao Qiang <qiang.zhao@nxp.com>
Subject: [PATCH v2 3/5] fsl/qe: Make regs resouce_size_t
Date: Thu, 2 Jun 2016 09:44:59 +0800
Message-ID: <1464831901-15913-3-git-send-email-qiang.zhao@nxp.com>
References: <1464831901-15913-1-git-send-email-qiang.zhao@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <xiaobo.xie@nxp.com>,
	Zhao Qiang <qiang.zhao@nxp.com>
To: <oss@buserror.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464831901-15913-1-git-send-email-qiang.zhao@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Zhao Qiang <qiang.zhao@nxp.com>
---
Changes for v2:
	- modify subject

 include/soc/fsl/qe/ucc_fast.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/soc/fsl/qe/ucc_fast.h b/include/soc/fsl/qe/ucc_fast.h
index b2633b7..e898895 100644
--- a/include/soc/fsl/qe/ucc_fast.h
+++ b/include/soc/fsl/qe/ucc_fast.h
@@ -123,7 +123,7 @@ struct ucc_fast_info {
 	enum qe_clock tx_clock;
 	enum qe_clock rx_sync;
 	enum qe_clock tx_sync;
-	u32 regs;
+	resource_size_t regs;
 	int irq;
 	u32 uccm_mask;
 	int bd_mem_part;
-- 
2.1.0.27.g96db324
