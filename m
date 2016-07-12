From: weiyj_lk@163.com
Subject: [PATCH -next] stmmac: dwmac-socfpga: fix wrong pointer passed to PTR_ERR()
Date: Tue, 12 Jul 2016 11:00:09 +0000
Message-ID: <1468321209-15732-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>, netdev@vger.kernel.org
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Alexandre Torgue <alexandre.torgue@st.com>,
	Tien Hock Loh <thloh@altera.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-16.163.com ([220.181.12.16]:32996 "EHLO m12-16.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932095AbcGLLAW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2016 07:00:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

PTR_ERR should access the value just tested by IS_ERR, otherwise
the wrong error code will be returned.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
index 4bee2f9..3bc1fa2 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
@@ -214,7 +214,7 @@ static int socfpga_dwmac_parse_data(struct socfpga_dwmac *dwmac, struct device *
 				dev_err(dev,
 					"%s: ERROR: failed mapping tse control port\n",
 					__func__);
-				return PTR_ERR(dwmac->pcs.sgmii_adapter_base);
+				return PTR_ERR(dwmac->pcs.tse_pcs_base);
 			}
 		}
 	}
