From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH 8/8] powerpc: get rid of CONFIG_8xx
Date: Thu, 12 Mar 2015 16:24:14 +0100 (CET)
Message-ID: <20150312152415.01E7C1A2423@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-fbdev@vger.kernel.org, linux-serial@vger.kernel.org,
 user-mode-linux-devel@lists.sourceforge.net, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mtd@lists.infradead.org,
 user-mode-linux-user@lists.sourceforge.net, linuxppc-dev@lists.ozlabs.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Vitaly Bordug <vitb@kernel.crashing.org>, scottwood@freescale.com
Return-path: <linux-mtd-bounces+gldm-linux-mtd-36=gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mtd>,
 <mailto:linux-mtd-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mtd/>
List-Post: <mailto:linux-mtd@lists.infradead.org>
List-Help: <mailto:linux-mtd-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mtd>,
 <mailto:linux-mtd-request@lists.infradead.org?subject=subscribe>
Sender: "linux-mtd" <linux-mtd-bounces@lists.infradead.org>
Errors-To: linux-mtd-bounces+gldm-linux-mtd-36=gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Two config options exist to define powerpc MPC8xx:
* CONFIG_PPC_8xx
* CONFIG_8xx
In addition, CONFIG_PPC_8xx also defines CONFIG_CPM1 as
communication co-processor

arch/powerpc/platforms/Kconfig.cputype has contained the following
comment about CONFIG_8xx item for some years:
"# this is temp to handle compat with arch=ppc"

It looks like not many places still have that old CONFIG_8xx used,
so it is likely to be a good time to get rid of it completely ?

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>

---
 arch/powerpc/platforms/Kconfig.cputype | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/arch/powerpc/platforms/Kconfig.cputype b/arch/powerpc/platforms/Kconfig.cputype
index 6d481ff..beca3ce 100644
--- a/arch/powerpc/platforms/Kconfig.cputype
+++ b/arch/powerpc/platforms/Kconfig.cputype
@@ -32,7 +32,6 @@ config PPC_85xx
 config PPC_8xx
 	bool "Freescale 8xx"
 	select FSL_SOC
-	select 8xx
 	select PPC_LIB_RHEAP
 
 config 40x
@@ -157,10 +156,6 @@ config TUNE_CELL
 	  itself, so the resulting kernel will keep running on all other
 	  machines.
 
-# this is temp to handle compat with arch=ppc
-config 8xx
-	bool
-
 config E500
 	select FSL_EMB_PERFMON
 	select PPC_FSL_BOOK3E
-- 
2.1.0


______________________________________________________
Linux MTD discussion mailing list
http://lists.infradead.org/mailman/listinfo/linux-mtd/
