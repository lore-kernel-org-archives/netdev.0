From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: [PATCH v4 2/5] clk: gxbb: expose MPLL2 clock for use by DT
Date: Sun,  4 Sep 2016 20:23:17 +0200
Message-ID: <20160904182320.671-3-martin.blumenstingl@googlemail.com>
References: <20160828161637.9941-1-martin.blumenstingl@googlemail.com>
 <20160904182320.671-1-martin.blumenstingl@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mark.rutland@arm.com, devicetree@vger.kernel.org, arnd@arndb.de,
 Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
 catalin.marinas@arm.com, manabian@gmail.com, will.deacon@arm.com,
 davem@davemloft.net, robh+dt@kernel.org, netdev@vger.kernel.org,
 sboyd@codeaurora.org, linux-arm-kernel@lists.infradead.org
To: linux-amlogic@lists.infradead.org, khilman@baylibre.com, carlo@caione.org,
 mturquette@baylibre.com, peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20160904182320.671-1-martin.blumenstingl@googlemail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

This exposes the MPLL2 clock as this is one of the input clocks of the
ethernet controller's internal mux.

Signed-off-by: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
---
 drivers/clk/meson/gxbb.h              | 2 +-
 include/dt-bindings/clock/gxbb-clkc.h | 1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/clk/meson/gxbb.h b/drivers/clk/meson/gxbb.h
index 217df51..3606e875 100644
--- a/drivers/clk/meson/gxbb.h
+++ b/drivers/clk/meson/gxbb.h
@@ -183,7 +183,7 @@
 /* CLKID_CLK81 */
 #define CLKID_MPLL0		  13
 #define CLKID_MPLL1		  14
-#define CLKID_MPLL2		  15
+/* CLKID_MPLL2 */
 #define CLKID_DDR		  16
 #define CLKID_DOS		  17
 #define CLKID_ISA		  18
diff --git a/include/dt-bindings/clock/gxbb-clkc.h b/include/dt-bindings/clock/gxbb-clkc.h
index 7d41864..244ea6e 100644
--- a/include/dt-bindings/clock/gxbb-clkc.h
+++ b/include/dt-bindings/clock/gxbb-clkc.h
@@ -8,6 +8,7 @@
 #define CLKID_CPUCLK		1
 #define CLKID_FCLK_DIV2		4
 #define CLKID_CLK81		12
+#define CLKID_MPLL2		15
 #define CLKID_ETH		36
 #define CLKID_SD_EMMC_A		94
 #define CLKID_SD_EMMC_B		95
-- 
2.9.3
