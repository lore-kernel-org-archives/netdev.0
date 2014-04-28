From: George Cherian <george.cherian@ti.com>
Subject: [PATCH 2/6] ARM: dts: am33xx: Add clock names for cpsw and cpts
Date: Mon, 28 Apr 2014 09:40:21 +0530
Message-ID: <1398658225-25873-3-git-send-email-george.cherian@ti.com>
References: <1398658225-25873-1-git-send-email-george.cherian@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mark.rutland@arm.com, tony@atomide.com, ast@plumgrid.com,
 mturquette@linaro.org, jeffrey.t.kirsher@intel.com, tklauser@distanz.ch,
 mugunthanvnm@ti.com, george.cherian@ti.com, pawel.moll@arm.com,
 ijc+devicetree@hellion.org.uk, richardcochran@gmail.com, robh+dt@kernel.org,
 bhutchings@solarflare.com, linux@arm.linux.org.uk, balbi@ti.com,
 zonque@gmail.com, t-kristo@ti.com, dborkman@redhat.com, bcousson@baylibre.com,
 galak@codeaurora.org, mpa@pengutronix.de, davem@davemloft.net
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
 <linux-arm-kernel@lists.infradead.org>, <devicetree@vger.kernel.org>,
 <linux-omap@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1398658225-25873-1-git-send-email-george.cherian@ti.com>
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

Add CPSW fck and CPTS clock and clock names

Signed-off-by: George Cherian <george.cherian@ti.com>
---
 arch/arm/boot/dts/am33xx.dtsi | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/arm/boot/dts/am33xx.dtsi b/arch/arm/boot/dts/am33xx.dtsi
index 9770e35..d1e2b36 100644
--- a/arch/arm/boot/dts/am33xx.dtsi
+++ b/arch/arm/boot/dts/am33xx.dtsi
@@ -665,6 +665,8 @@
 		mac: ethernet@4a100000 {
 			compatible = "ti,cpsw";
 			ti,hwmods = "cpgmac0";
+			clocks = <&cpsw_125mhz_gclk>, <&cpsw_cpts_rft_clk>;
+			clock-names = "fck", "cpts";
 			cpdma_channels = <8>;
 			ale_entries = <1024>;
 			bd_ram_size = <0x2000>;
-- 
1.8.3.1
