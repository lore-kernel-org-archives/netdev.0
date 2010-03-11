From: Sriramakrishnan <srk-l0cyMroinI0@public.gmane.org>
Subject: [PATCH 3/4] OMAP3 : clock data: Update name string for EMAC clocks.
Date: Thu, 11 Mar 2010 20:43:41 +0530
Message-ID: <1268320422-32656-4-git-send-email-srk@ti.com>
References: <1268320422-32656-1-git-send-email-srk@ti.com>
	<1268320422-32656-2-git-send-email-srk@ti.com>
	<1268320422-32656-3-git-send-email-srk@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sriramakrishnan <srk-l0cyMroinI0@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
To: linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
In-Reply-To: <1268320422-32656-3-git-send-email-srk-l0cyMroinI0@public.gmane.org>
List-Unsubscribe: <http://linux.davincidsp.com/mailman/options/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=unsubscribe>
List-Archive: <http://linux.davincidsp.com/pipermail/davinci-linux-open-source>
List-Post: <mailto:davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
List-Help: <mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=help>
List-Subscribe: <http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=subscribe>
Sender: davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
Errors-To: davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
List-Id: netdev.vger.kernel.org

The emac driver uses generic name for the module and phy
clocks. Updated the omap3xxx_clks table to match the names
used by the Davinci emac driver.

Signed-off-by: Sriramakrishnan <srk-l0cyMroinI0@public.gmane.org>
---
 arch/arm/mach-omap2/clock3xxx_data.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/arm/mach-omap2/clock3xxx_data.c b/arch/arm/mach-omap2/clock3xxx_data.c
index d5153b6..989da2e 100644
--- a/arch/arm/mach-omap2/clock3xxx_data.c
+++ b/arch/arm/mach-omap2/clock3xxx_data.c
@@ -3472,8 +3472,8 @@ static struct omap_clk omap3xxx_clks[] = {
 	CLK(NULL,	"ipss_ick",	&ipss_ick,	CK_AM35XX),
 	CLK(NULL,	"rmii_ck",	&rmii_ck,	CK_AM35XX),
 	CLK(NULL,	"pclk_ck",	&pclk_ck,	CK_AM35XX),
-	CLK("davinci_emac",	"ick",		&emac_ick,	CK_AM35XX),
-	CLK("davinci_emac",	"fck",		&emac_fck,	CK_AM35XX),
+	CLK("davinci_emac",	"emac_clk",	&emac_ick,	CK_AM35XX),
+	CLK("davinci_emac",	"phy_clk",	&emac_fck,	CK_AM35XX),
 	CLK("vpfe-capture",	"master",	&vpfe_ick,	CK_AM35XX),
 	CLK("vpfe-capture",	"slave",	&vpfe_fck,	CK_AM35XX),
 	CLK("musb_hdrc",	"ick",		&hsotgusb_ick_am35xx,	CK_AM35XX),
-- 
1.6.2.4
