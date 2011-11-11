From: Richard Zhao <richard.zhao@linaro.org>
Subject: [PATCH V2 08/14] ARM: pm-imx5: add clk_prepare/clk_unprepare
Date: Fri, 11 Nov 2011 09:10:23 +0800
Message-ID: <1320973829-4388-9-git-send-email-richard.zhao@linaro.org>
References: <1320973829-4388-1-git-send-email-richard.zhao@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: amit.kucheria@canonical.com, linux@arm.linux.org.uk, kernel@pengutronix.de,
 eric.miao@linaro.org, ben-linux@fluff.org, cjb@laptop.org,
 Richard Zhao <richard.zhao@linaro.org>, alan@linux.intel.com
To: <linux-arm-kernel@lists.infradead.org>, <linux-i2c@vger.kernel.org>,
 <linux-mmc@vger.kernel.org>, <netdev@vger.kernel.org>,
 <linux-serial@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1320973829-4388-1-git-send-email-richard.zhao@linaro.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Richard Zhao <richard.zhao@linaro.org>
---
 arch/arm/mach-mx5/pm-imx5.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/arm/mach-mx5/pm-imx5.c b/arch/arm/mach-mx5/pm-imx5.c
index 98052fc..2bdc85f 100644
--- a/arch/arm/mach-mx5/pm-imx5.c
+++ b/arch/arm/mach-mx5/pm-imx5.c
@@ -22,7 +22,7 @@ static struct clk *gpc_dvfs_clk;
 
 static int mx5_suspend_prepare(void)
 {
-	return clk_enable(gpc_dvfs_clk);
+	return clk_prepare_enable(gpc_dvfs_clk);
 }
 
 static int mx5_suspend_enter(suspend_state_t state)
@@ -52,7 +52,7 @@ static int mx5_suspend_enter(suspend_state_t state)
 
 static void mx5_suspend_finish(void)
 {
-	clk_disable(gpc_dvfs_clk);
+	clk_disable_unprepare(gpc_dvfs_clk);
 }
 
 static int mx5_pm_valid(suspend_state_t state)
-- 
1.7.5.4
