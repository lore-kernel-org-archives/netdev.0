From: <panduranga_mallireddy@ti.com>
Subject: [PATCH 1/1] OMAP: wlan: Set the WLAN Regulator to be
	always on
Date: Tue, 16 Aug 2011 10:03:57 -0500
Message-ID: <1313507037-2467-2-git-send-email-panduranga_mallireddy@ti.com>
References: <1313507037-2467-1-git-send-email-panduranga_mallireddy@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ohad@wizery.com, Panduranga Mallireddy <panduranga_mallireddy@ti.com>,
        pradeepgurumath@ti.com, coelho@ti.com, netdev@vger.kernel.org,
        naveen_jain@ti.com, x-boudet@ti.com, vishalm@ti.com,
        manjunatha_halli@ti.com, benzyg@ti.com, linux-omap@vger.kernel.org
To: <stable@kernel.org>
Return-path: <stable-bounces@linux.kernel.org>
In-Reply-To: <1313507037-2467-1-git-send-email-panduranga_mallireddy@ti.com>
List-Unsubscribe: <http://linux.kernel.org/mailman/options/stable>,
	<mailto:stable-request@linux.kernel.org?subject=unsubscribe>
List-Archive: <http://linux.kernel.org/mailman/private/stable/>
List-Post: <mailto:stable@linux.kernel.org>
List-Help: <mailto:stable-request@linux.kernel.org?subject=help>
List-Subscribe: <http://linux.kernel.org/mailman/listinfo/stable>,
	<mailto:stable-request@linux.kernel.org?subject=subscribe>
Sender: stable-bounces@linux.kernel.org
Errors-To: stable-bounces@linux.kernel.org
List-Id: netdev.vger.kernel.org

From: Panduranga Mallireddy <panduranga_mallireddy@ti.com>

For regulator omap4_clk32k used by wlan, set .constraints.always_on to 1.
This regulator should never be disabled.

Signed-off-by: Panduranga Mallireddy <panduranga_mallireddy@ti.com>
---
 arch/arm/mach-omap2/twl-common.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/arch/arm/mach-omap2/twl-common.c b/arch/arm/mach-omap2/twl-common.c
index 2543342..536ad71 100644
--- a/arch/arm/mach-omap2/twl-common.c
+++ b/arch/arm/mach-omap2/twl-common.c
@@ -229,6 +229,7 @@ static struct regulator_init_data omap4_vusb_idata = {
 static struct regulator_init_data omap4_clk32kg_idata = {
 	.constraints = {
 		.valid_ops_mask		= REGULATOR_CHANGE_STATUS,
+		.always_on			= true,
 	},
 };
 
-- 
1.7.1

_______________________________________________
stable mailing list
stable@linux.kernel.org
http://linux.kernel.org/mailman/listinfo/stable
