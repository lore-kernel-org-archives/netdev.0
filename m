From: <srinivas.kandagatla@st.com>
Subject: [PATCH RFC 06/10] ARM: STi: Add reset controller support to mach-sti
 Kconfig
Date: Tue, 12 Nov 2013 13:52:51 +0000
Message-ID: <1384264371-7568-1-git-send-email-srinivas.kandagatla@st.com>
References: <1384264311-7308-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, Len Brown <len.brown@intel.com>,
 Russell King <linux@arm.linux.org.uk>, Pavel Machek <pavel@ucw.cz>,
 Pawel Moll <pawel.moll@arm.com>, Ian Campbell <ijc+devicetree@hellion.org.uk>,
 Srinivas Kandagatla <srinivas.kandagatla@st.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-pm@vger.kernel.org,
 Stephen Warren <swarren@wwwdotorg.org>,
 "Rafael J. Wysocki" <rjw@rjwysocki.net>, stephen.gallimore@st.com,
 Rob Herring <rob.herring@calxeda.com>, linux-doc@vger.kernel.org,
 Stuart Menefy <stuart.menefy@st.com>, devicetree@vger.kernel.org,
 Rob Landley <rob@landley.net>, Grant Likely <grant.likely@linaro.org>,
 Giuseppe Cavallaro <peppe.cavallaro@st.com>, linux-kernel@vger.kernel.org,
 kernel@stlinux.com
To: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1384264311-7308-1-git-send-email-srinivas.kandagatla@st.com>
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

From: Stephen Gallimore <stephen.gallimore@st.com>

This patch selects reset controller support for ARCH_STI and
selects the reset controllers for STiH415 and STiH416 SoCs.

Signed-off-by: Stephen Gallimore <stephen.gallimore@st.com>
---
 arch/arm/mach-sti/Kconfig |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/arch/arm/mach-sti/Kconfig b/arch/arm/mach-sti/Kconfig
index 835833e..b7c527e 100644
--- a/arch/arm/mach-sti/Kconfig
+++ b/arch/arm/mach-sti/Kconfig
@@ -7,6 +7,7 @@ menuconfig ARCH_STI
 	select PINCTRL
 	select PINCTRL_ST
 	select MFD_SYSCON
+	select ARCH_HAS_RESET_CONTROLLER
 	select MIGHT_HAVE_CACHE_L2X0
 	select HAVE_SMP
 	select HAVE_ARM_SCU if SMP
@@ -28,6 +29,7 @@ if ARCH_STI
 config SOC_STIH415
 	bool "STiH415 STMicroelectronics Consumer Electronics family"
 	default y
+	select STIH415_RESET
 	help
 	  This enables support for STMicroelectronics Digital Consumer
 	  Electronics family StiH415 parts, primarily targetted at set-top-box
@@ -37,6 +39,7 @@ config SOC_STIH415
 config SOC_STIH416
 	bool "STiH416 STMicroelectronics Consumer Electronics family"
 	default y
+	select STIH416_RESET
 	help
 	  This enables support for STMicroelectronics Digital Consumer
 	  Electronics family StiH416 parts, primarily targetted at set-top-box
-- 
1.7.6.5
