From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH] powerpc/ep8248e: phylib needs NET_SCHED to build
Date: Wed, 20 May 2009 16:18:22 +0400
Message-ID: <1242821902-16836-1-git-send-email-a.beregalov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alexander Beregalov <a.beregalov@gmail.com>
To: galak@kernel.crashing.org,
	linuxppc-dev@ozlabs.org
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Fix this build error:
drivers/built-in.o: In function `phy_state_machine':
drivers/net/phy/phy.c:893: undefined reference to 'netif_carrier_off'
drivers/net/phy/phy.c:854: undefined reference to 'netif_carrier_on'

Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 arch/powerpc/platforms/82xx/Kconfig |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/arch/powerpc/platforms/82xx/Kconfig b/arch/powerpc/platforms/82xx/Kconfig
index 7c7df40..36a3e58 100644
--- a/arch/powerpc/platforms/82xx/Kconfig
+++ b/arch/powerpc/platforms/82xx/Kconfig
@@ -31,6 +31,9 @@ config EP8248E
 	select 8260
 	select FSL_SOC
 	select PHYLIB
+	select NET
+	select NETDEVICE
+	select NET_SCHED
 	select MDIO_BITBANG
 	help
 	  This enables support for the Embedded Planet EP8248E board.
-- 
1.6.2.4
