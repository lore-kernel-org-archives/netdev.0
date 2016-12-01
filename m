From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH 5/7] Documentation: DT: net: cpsw: allow to specify descriptors pool size
Date: Thu, 1 Dec 2016 17:34:30 -0600
Message-ID: <20161201233432.6182-6-grygorii.strashko@ti.com>
References: <20161201233432.6182-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161201233432.6182-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add optional property "descs_pool_size" to specify buffer descriptor's
pool size. The "descs_pool_size" should define total number of CPDMA
CPPI descriptors to be used for both ingress/egress packets
processing. If not specified - the default value 256 will be used
which will allow to place descriptor's pool into the internal CPPI
RAM on most of TI SoC.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 Documentation/devicetree/bindings/net/cpsw.txt | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
index 5ad439f..b99d196 100644
--- a/Documentation/devicetree/bindings/net/cpsw.txt
+++ b/Documentation/devicetree/bindings/net/cpsw.txt
@@ -35,6 +35,11 @@ Optional properties:
 			  For example in dra72x-evm, pcf gpio has to be
 			  driven low so that cpsw slave 0 and phy data
 			  lines are connected via mux.
+- descs_pool_size	: total number of CPDMA CPPI descriptors to be used for
+			  both ingress/egress packets processing. if not
+			  specified the default value 256 will be used which
+			  will allow to place descriptors pool into the
+			  internal CPPI RAM.
 
 
 Slave Properties:
-- 
2.10.1
