From: George Cherian <george.cherian@ti.com>
Subject: [PATCH 0/6] Add CPTS support for AM437x
Date: Mon, 28 Apr 2014 09:40:19 +0530
Message-ID: <1398658225-25873-1-git-send-email-george.cherian@ti.com>
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

The series adds CPTS support for AM4372.

Patch 1 - CPTS clock name harcoding in the driver is removed. 
	  Easier to pass the clock name from dt rather than hardcoding in driver.
	  Also in prepration for DRA7x CPTS support.
Patch 2 - DT changes w.r.t clock changes for AM33xx.
Patch 3 - Enable the CPTS support for both DRA7x and AM4372 in the driver.
Patch 4 - Enable the Annexe F for L2 PTP for AM437x and DRA7x.
Patch 5 - Change the default clocksource to dpll_core_m5 
Patch 6 - DT changes for AM4372.
 
George Cherian (6):
  drivers: net: cpts: Remove hardcoded clock name for CPTS
  ARM: dts: am33xx: Add clock names for cpsw and cpts
  drivers: net: cpsw: Enable CPTS for DRA7xx and AM4372
  drivers: net: cpsw: Enable Annexe F Time sync
  ARM: AM43xx: clk: Change the cpts ref clock source to dpll_core_m5 clk
  ARM: dts: am4372: Add clock names for cpsw and cpts

 arch/arm/boot/dts/am33xx.dtsi  |  2 ++
 arch/arm/boot/dts/am4372.dtsi  |  2 ++
 drivers/clk/ti/clk-43xx.c      | 16 ++++++++++++++++
 drivers/net/ethernet/ti/cpsw.c | 15 ++++++++++-----
 drivers/net/ethernet/ti/cpts.c | 11 ++++-------
 5 files changed, 34 insertions(+), 12 deletions(-)

-- 
1.8.3.1
