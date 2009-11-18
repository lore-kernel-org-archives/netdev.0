From: Dave Mitchell <dmitchell@appliedmicro.com>
Subject: [PATCH] ibm_newemac: Fix EMACx_TRTR[TRT] bit shifts
Date: Tue, 17 Nov 2009 18:56:55 -0600
Message-ID: <1258505815-31261-1-git-send-email-dmitchell@appliedmicro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, dmitchell@appliedmicro.com
To: netdev@vger.kernel.org
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

The TRT bit shifts were reversed for EMAC4 and non-EMAC4 during the 
port from ibm_emac to ibm_newemac. This patch corrects that error.

Signed-off-by: Dave Mitchell <dmitchell@appliedmicro.com>
Acked-by: Feng Kan <fkan@appliedmicro.com>
Acked-by: Prodyut Hazarika <phazarika@appliedmicro.com>
---
 For those curious, these bits control the TX threshold.
 
 drivers/net/ibm_newemac/emac.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ibm_newemac/emac.h b/drivers/net/ibm_newemac/emac.h
index d34adf9..f2751cb 100644
--- a/drivers/net/ibm_newemac/emac.h
+++ b/drivers/net/ibm_newemac/emac.h
@@ -263,8 +263,8 @@ struct emac_regs {
 
 
 /* EMACx_TRTR */
-#define EMAC_TRTR_SHIFT_EMAC4		27
-#define EMAC_TRTR_SHIFT			24
+#define EMAC_TRTR_SHIFT_EMAC4		24
+#define EMAC_TRTR_SHIFT		27
 
 /* EMAC specific TX descriptor control fields (write access) */
 #define EMAC_TX_CTRL_GFCS		0x0200
-- 
1.6.3.2
