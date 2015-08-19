From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH v1 4/6] ARM: dts: imx: pinfunc: add GPIO1 pin define for i.MX7d
Date: Wed, 19 Aug 2015 13:34:02 +0800
Message-ID: <1439962444-27486-5-git-send-email-b38611@freescale.com>
References: <1439962444-27486-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b38611@freescale.com,
 linux-arm-kernel@lists.infradead.org
To: <shawnguo@kernel.org>, <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1439962444-27486-1-git-send-email-b38611@freescale.com>
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

Add GPIO1 pin define for i.MX7d.

Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 arch/arm/boot/dts/imx7d-pinfunc.h | 115 ++++++++++++++++++++++++++++++++++++++
 1 file changed, 115 insertions(+)

diff --git a/arch/arm/boot/dts/imx7d-pinfunc.h b/arch/arm/boot/dts/imx7d-pinfunc.h
index a8d8149..8b3cf2bc 100644
--- a/arch/arm/boot/dts/imx7d-pinfunc.h
+++ b/arch/arm/boot/dts/imx7d-pinfunc.h
@@ -15,6 +15,121 @@
  * <mux_reg conf_reg input_reg mux_mode input_val>
  */
 
+#define MX7D_PAD_GPIO1_IO00__GPIO1_IO0				  0x0000 0x0030 0x0000 0x0 0x0
+#define MX7D_PAD_GPIO1_IO00__PWM4_OUT				  0x0000 0x0030 0x0000 0x1 0x0
+#define MX7D_PAD_GPIO1_IO00__WDOD1_WDOG_ANY			  0x0000 0x0030 0x0000 0x2 0x0
+#define MX7D_PAD_GPIO1_IO00__WDOD1_WDOG_B			  0x0000 0x0030 0x0000 0x3 0x0
+#define MX7D_PAD_GPIO1_IO00__WDOD1_WDOG__RST_B_DEB		  0x0000 0x0030 0x0000 0x4 0x0
+#define MX7D_PAD_GPIO1_IO01__GPIO1_IO1				  0x0004 0x0034 0x0000 0x0 0x0
+#define MX7D_PAD_GPIO1_IO01__PWM1_OUT				  0x0004 0x0034 0x0000 0x1 0x0
+#define MX7D_PAD_GPIO1_IO01__CCM_ENET_REF_CLK3			  0x0004 0x0034 0x0000 0x2 0x0
+#define MX7D_PAD_GPIO1_IO01__SAI1_MCLK				  0x0004 0x0034 0x0000 0x3 0x0
+#define MX7D_PAD_GPIO1_IO01__OBSERVE0_OUT			  0x0004 0x0034 0x0000 0x6 0x0
+#define MX7D_PAD_GPIO1_IO02__GPIO1_IO2				  0x0008 0x0038 0x0000 0x0 0x0
+#define MX7D_PAD_GPIO1_IO02__PWM2_OUT				  0x0008 0x0038 0x0000 0x1 0x0
+#define MX7D_PAD_GPIO1_IO02__CCM_ENET_REF_CLK1			  0x0008 0x0038 0x0564 0x2 0x3
+#define MX7D_PAD_GPIO1_IO02__SAI2_MCLK				  0x0008 0x0038 0x0000 0x3 0x0
+#define MX7D_PAD_GPIO1_IO02__CCM_CLKO1				  0x0008 0x0038 0x0000 0x5 0x0
+#define MX7D_PAD_GPIO1_IO02__OBSERVE1_OUT			  0x0008 0x0038 0x0000 0x6 0x0
+#define MX7D_PAD_GPIO1_IO02__USB_OTG1_ID			  0x0008 0x0038 0x0734 0x7 0x3
+#define MX7D_PAD_GPIO1_IO03__GPIO1_IO3				  0x000C 0x003C 0x0000 0x0 0x0
+#define MX7D_PAD_GPIO1_IO03__PWM3_OUT				  0x000C 0x003C 0x0000 0x1 0x0
+#define MX7D_PAD_GPIO1_IO03__CCM_ENET_REF_CLK2			  0x000C 0x003C 0x0570 0x2 0x3
+#define MX7D_PAD_GPIO1_IO03__SAI3_MCLK				  0x000C 0x003C 0x0000 0x3 0x0
+#define MX7D_PAD_GPIO1_IO03__CCM_CLKO2				  0x000C 0x003C 0x0000 0x5 0x0
+#define MX7D_PAD_GPIO1_IO03__OBSERVE2_OUT			  0x000C 0x003C 0x0000 0x6 0x0
+#define MX7D_PAD_GPIO1_IO03__USB_OTG2_ID			  0x000C 0x003C 0x0730 0x7 0x3
+#define MX7D_PAD_GPIO1_IO04__GPIO1_IO4				  0x0010 0x0040 0x0000 0x0 0x0
+#define MX7D_PAD_GPIO1_IO04__USB_OTG1_OC			  0x0010 0x0040 0x072C 0x1 0x1
+#define MX7D_PAD_GPIO1_IO04__FLEXTIMER1_CH4			  0x0010 0x0040 0x0594 0x2 0x1
+#define MX7D_PAD_GPIO1_IO04__UART5_CTS_B			  0x0010 0x0040 0x0710 0x3 0x4
+#define MX7D_PAD_GPIO1_IO04__I2C1_SCL				  0x0010 0x0040 0x05D4 0x4 0x2
+#define MX7D_PAD_GPIO1_IO04__OBSERVE3_OUT			  0x0010 0x0040 0x0000 0x6 0x0
+#define MX7D_PAD_GPIO1_IO05__GPIO1_IO5				  0x0014 0x0044 0x0000 0x0 0x0
+#define MX7D_PAD_GPIO1_IO05__USB_OTG1_PWR			  0x0014 0x0044 0x0000 0x1 0x0
+#define MX7D_PAD_GPIO1_IO05__FLEXTIMER1_CH5			  0x0014 0x0044 0x0598 0x2 0x1
+#define MX7D_PAD_GPIO1_IO05__UART5_RTS_B			  0x0014 0x0044 0x0710 0x3 0x5
+#define MX7D_PAD_GPIO1_IO05__I2C1_SDA				  0x0014 0x0044 0x05D8 0x4 0x2
+#define MX7D_PAD_GPIO1_IO05__OBSERVE4_OUT			  0x0014 0x0044 0x0000 0x6 0x0
+#define MX7D_PAD_GPIO1_IO06__GPIO1_IO6				  0x0018 0x0048 0x0000 0x0 0x0
+#define MX7D_PAD_GPIO1_IO06__USB_OTG2_OC			  0x0018 0x0048 0x0728 0x1 0x1
+#define MX7D_PAD_GPIO1_IO06__FLEXTIMER1_CH6			  0x0018 0x0048 0x059C 0x2 0x1
+#define MX7D_PAD_GPIO1_IO06__UART5_RX_DATA			  0x0018 0x0048 0x0714 0x3 0x4
+#define MX7D_PAD_GPIO1_IO06__I2C2_SCL				  0x0018 0x0048 0x05DC 0x4 0x2
+#define MX7D_PAD_GPIO1_IO06__CCM_WAIT				  0x0018 0x0048 0x0000 0x5 0x0
+#define MX7D_PAD_GPIO1_IO06__KPP_ROW4				  0x0018 0x0048 0x0624 0x6 0x1
+#define MX7D_PAD_GPIO1_IO07__GPIO1_IO7				  0x001C 0x004C 0x0000 0x0 0x0
+#define MX7D_PAD_GPIO1_IO07__USB_OTG2_PWR			  0x001C 0x004C 0x0000 0x1 0x0
+#define MX7D_PAD_GPIO1_IO07__FLEXTIMER1_CH7			  0x001C 0x004C 0x05A0 0x2 0x1
+#define MX7D_PAD_GPIO1_IO07__UART5_TX_DATA			  0x001C 0x004C 0x0714 0x3 0x5
+#define MX7D_PAD_GPIO1_IO07__I2C2_SDA				  0x001C 0x004C 0x05E0 0x4 0x2
+#define MX7D_PAD_GPIO1_IO07__CCM_STOP				  0x001C 0x004C 0x0000 0x5 0x0
+#define MX7D_PAD_GPIO1_IO07__KPP_COL4				  0x001C 0x004C 0x0604 0x6 0x1
+#define MX7D_PAD_GPIO1_IO08__GPIO1_IO8                            0x0014 0x026C 0x0000 0x0 0x0
+#define MX7D_PAD_GPIO1_IO08__SD1_VSELECT                          0x0014 0x026C 0x0000 0x1 0x0
+#define MX7D_PAD_GPIO1_IO08__WDOG1_WDOG_B                         0x0014 0x026C 0x0000 0x2 0x0
+#define MX7D_PAD_GPIO1_IO08__UART3_DCE_RX                         0x0014 0x026C 0x0704 0x3 0x0
+#define MX7D_PAD_GPIO1_IO08__UART3_DTE_TX                         0x0014 0x026C 0x0000 0x3 0x0
+#define MX7D_PAD_GPIO1_IO08__I2C3_SCL                             0x0014 0x026C 0x05E4 0x4 0x0
+#define MX7D_PAD_GPIO1_IO08__KPP_COL5                             0x0014 0x026C 0x0608 0x6 0x0
+#define MX7D_PAD_GPIO1_IO08__PWM1_OUT                             0x0014 0x026C 0x0000 0x7 0x0
+#define MX7D_PAD_GPIO1_IO09__GPIO1_IO9                            0x0018 0x0270 0x0000 0x0 0x0
+#define MX7D_PAD_GPIO1_IO09__SD1_LCTL                             0x0018 0x0270 0x0000 0x1 0x0
+#define MX7D_PAD_GPIO1_IO09__CCM_ENET_REF_CLK3                    0x0018 0x0270 0x0000 0x2 0x0
+#define MX7D_PAD_GPIO1_IO09__UART3_DCE_TX                         0x0018 0x0270 0x0000 0x3 0x0
+#define MX7D_PAD_GPIO1_IO09__UART3_DTE_RX                         0x0018 0x0270 0x0704 0x3 0x1
+#define MX7D_PAD_GPIO1_IO09__I2C3_SDA                             0x0018 0x0270 0x05E8 0x4 0x0
+#define MX7D_PAD_GPIO1_IO09__CCM_PMIC_READY                       0x0018 0x0270 0x04F4 0x5 0x0
+#define MX7D_PAD_GPIO1_IO09__KPP_ROW5                             0x0018 0x0270 0x0628 0x6 0x0
+#define MX7D_PAD_GPIO1_IO09__PWM2_OUT                             0x0018 0x0270 0x0000 0x7 0x0
+#define MX7D_PAD_GPIO1_IO10__GPIO1_IO10                           0x001C 0x0274 0x0000 0x0 0x0
+#define MX7D_PAD_GPIO1_IO10__SD2_LCTL                             0x001C 0x0274 0x0000 0x1 0x0
+#define MX7D_PAD_GPIO1_IO10__ENET1_MDIO                           0x001C 0x0274 0x0568 0x2 0x0
+#define MX7D_PAD_GPIO1_IO10__UART3_DCE_RTS                        0x001C 0x0274 0x0700 0x3 0x0
+#define MX7D_PAD_GPIO1_IO10__UART3_DTE_CTS                        0x001C 0x0274 0x0000 0x3 0x0
+#define MX7D_PAD_GPIO1_IO10__I2C4_SCL                             0x001C 0x0274 0x05EC 0x4 0x0
+#define MX7D_PAD_GPIO1_IO10__FLEXTIMER1_PHA                       0x001C 0x0274 0x05A4 0x5 0x0
+#define MX7D_PAD_GPIO1_IO10__KPP_COL6                             0x001C 0x0274 0x060C 0x6 0x0
+#define MX7D_PAD_GPIO1_IO10__PWM3_OUT                             0x001C 0x0274 0x0000 0x7 0x0
+#define MX7D_PAD_GPIO1_IO11__GPIO1_IO11                           0x0020 0x0278 0x0000 0x0 0x0
+#define MX7D_PAD_GPIO1_IO11__SD3_LCTL                             0x0020 0x0278 0x0000 0x1 0x0
+#define MX7D_PAD_GPIO1_IO11__ENET1_MDC                            0x0020 0x0278 0x0000 0x2 0x0
+#define MX7D_PAD_GPIO1_IO11__UART3_DCE_CTS                        0x0020 0x0278 0x0000 0x3 0x0
+#define MX7D_PAD_GPIO1_IO11__UART3_DTE_RTS                        0x0020 0x0278 0x0700 0x3 0x1
+#define MX7D_PAD_GPIO1_IO11__I2C4_SDA                             0x0020 0x0278 0x05F0 0x4 0x0
+#define MX7D_PAD_GPIO1_IO11__FLEXTIMER1_PHB                       0x0020 0x0278 0x05A8 0x5 0x0
+#define MX7D_PAD_GPIO1_IO11__KPP_ROW6                             0x0020 0x0278 0x062C 0x6 0x0
+#define MX7D_PAD_GPIO1_IO11__PWM4_OUT                             0x0020 0x0278 0x0000 0x7 0x0
+#define MX7D_PAD_GPIO1_IO12__GPIO1_IO12                           0x0024 0x027C 0x0000 0x0 0x0
+#define MX7D_PAD_GPIO1_IO12__SD2_VSELECT                          0x0024 0x027C 0x0000 0x1 0x0
+#define MX7D_PAD_GPIO1_IO12__CCM_ENET_REF_CLK1                    0x0024 0x027C 0x0564 0x2 0x0
+#define MX7D_PAD_GPIO1_IO12__FLEXCAN1_RX                          0x0024 0x027C 0x04DC 0x3 0x0
+#define MX7D_PAD_GPIO1_IO12__CM4_NMI                              0x0024 0x027C 0x0000 0x4 0x0
+#define MX7D_PAD_GPIO1_IO12__CCM_EXT_CLK1                         0x0024 0x027C 0x04E4 0x5 0x0
+#define MX7D_PAD_GPIO1_IO12__SNVS_VIO_5                           0x0024 0x027C 0x0000 0x6 0x0
+#define MX7D_PAD_GPIO1_IO12__USB_OTG1_ID                          0x0024 0x027C 0x0734 0x7 0x0
+#define MX7D_PAD_GPIO1_IO13__GPIO1_IO13                           0x0028 0x0280 0x0000 0x0 0x0
+#define MX7D_PAD_GPIO1_IO13__SD3_VSELECT                          0x0028 0x0280 0x0000 0x1 0x0
+#define MX7D_PAD_GPIO1_IO13__CCM_ENET_REF_CLK2                    0x0028 0x0280 0x0570 0x2 0x0
+#define MX7D_PAD_GPIO1_IO13__FLEXCAN1_TX                          0x0028 0x0280 0x0000 0x3 0x0
+#define MX7D_PAD_GPIO1_IO13__CCM_PMIC_READY                       0x0028 0x0280 0x04F4 0x4 0x1
+#define MX7D_PAD_GPIO1_IO13__CCM_EXT_CLK2                         0x0028 0x0280 0x04E8 0x5 0x0
+#define MX7D_PAD_GPIO1_IO13__SNVS_VIO_5_CTL                       0x0028 0x0280 0x0000 0x6 0x0
+#define MX7D_PAD_GPIO1_IO13__USB_OTG2_ID                          0x0028 0x0280 0x0730 0x7 0x0
+#define MX7D_PAD_GPIO1_IO14__GPIO1_IO14                           0x002C 0x0284 0x0000 0x0 0x0
+#define MX7D_PAD_GPIO1_IO14__SD3_CD_B                             0x002C 0x0284 0x0738 0x1 0x0
+#define MX7D_PAD_GPIO1_IO14__ENET2_MDIO                           0x002C 0x0284 0x0574 0x2 0x0
+#define MX7D_PAD_GPIO1_IO14__FLEXCAN2_RX                          0x002C 0x0284 0x04E0 0x3 0x0
+#define MX7D_PAD_GPIO1_IO14__WDOG3_WDOG_B                         0x002C 0x0284 0x0000 0x4 0x0
+#define MX7D_PAD_GPIO1_IO14__CCM_EXT_CLK3                         0x002C 0x0284 0x04EC 0x5 0x0
+#define MX7D_PAD_GPIO1_IO14__SDMA_EXT_EVENT0                      0x002C 0x0284 0x06D8 0x6 0x0
+#define MX7D_PAD_GPIO1_IO15__GPIO1_IO15                           0x0030 0x0288 0x0000 0x0 0x0
+#define MX7D_PAD_GPIO1_IO15__SD3_WP                               0x0030 0x0288 0x073C 0x1 0x0
+#define MX7D_PAD_GPIO1_IO15__ENET2_MDC                            0x0030 0x0288 0x0000 0x2 0x0
+#define MX7D_PAD_GPIO1_IO15__FLEXCAN2_TX                          0x0030 0x0288 0x0000 0x3 0x0
+#define MX7D_PAD_GPIO1_IO15__WDOG4_WDOG_B                         0x0030 0x0288 0x0000 0x4 0x0
+#define MX7D_PAD_GPIO1_IO15__CCM_EXT_CLK4                         0x0030 0x0288 0x04F0 0x5 0x0
+#define MX7D_PAD_GPIO1_IO15__SDMA_EXT_EVENT1                      0x0030 0x0288 0x06DC 0x6 0x0
 #define MX7D_PAD_EPDC_DATA00__EPDC_DATA0                          0x0034 0x02A4 0x0000 0x0 0x0
 #define MX7D_PAD_EPDC_DATA00__SIM1_PORT2_TRXD                     0x0034 0x02A4 0x0000 0x1 0x0
 #define MX7D_PAD_EPDC_DATA00__QSPI_A_DATA0                        0x0034 0x02A4 0x0000 0x2 0x0
-- 
1.9.1
