From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH 2/2] arm64: dts: apq8016-sbc: Correct WLAN LED default-trigger
Date: Wed, 26 Apr 2017 15:04:44 -0700
Message-ID: <20170426220444.10539-2-bjorn.andersson@linaro.org>
References: <20170426220444.10539-1-bjorn.andersson@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, linux-arm-msm@vger.kernel.org,
 linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
 Kalle Valo <kvalo@codeaurora.org>, netdev@vger.kernel.org,
 Nicolas Dechesne <nicolas.dechesne@linaro.org>, wcn36xx@lists.infradead.org,
 linux-soc@vger.kernel.org, Eugene Krasnikov <k.eugene.e@gmail.com>,
 linux-arm-kernel@lists.infradead.org
To: Andy Gross <andy.gross@linaro.org>,
	David Brown <david.brown@linaro.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170426220444.10539-1-bjorn.andersson@linaro.org>
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

The TX status trigger of the wlan interface is named phy0tx, so this
updates the default-trigger for the WLAN LED to use that instead.

Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---

Note that without patch 1/2 this trigger does not fire - but there's also no
harm in picking the two patches through separate trees.

 arch/arm64/boot/dts/qcom/apq8016-sbc.dtsi | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/arm64/boot/dts/qcom/apq8016-sbc.dtsi b/arch/arm64/boot/dts/qcom/apq8016-sbc.dtsi
index 5d83b02b7c4a..21a8f5ce8955 100644
--- a/arch/arm64/boot/dts/qcom/apq8016-sbc.dtsi
+++ b/arch/arm64/boot/dts/qcom/apq8016-sbc.dtsi
@@ -178,7 +178,7 @@
 			led@5 {
 				label = "apq8016-sbc:yellow:wlan";
 				gpios = <&pm8916_mpps 2 GPIO_ACTIVE_HIGH>;
-				linux,default-trigger = "wlan";
+				linux,default-trigger = "phy0tx";
 				default-state = "off";
 			};
 
-- 
2.12.0
