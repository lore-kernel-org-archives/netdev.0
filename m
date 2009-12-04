From: Amit Kucheria <amit.kucheria@canonical.com>
Subject: [RFC][PATCH 09/10] fec: Add ARCH_MX5 as a dependency
Date: Fri,  4 Dec 2009 04:47:09 +0200
Message-ID: <2a48ec938005ba7e32a4acc10c1820888003bec8.1259893118.git.amit.kucheria@canonical.com>
References: <cover.1259893118.git.amit.kucheria@canonical.com>
	<e99e70e2a619693064130a747b6ee3a93273337b.1259893118.git.amit.kucheria@canonical.com>
	<6608c4dca645d87efce78ae0b7dbad265004f482.1259893118.git.amit.kucheria@canonical.com>
	<58eb7d14c6cf56cbc874657dff5789c47116b49e.1259893118.git.amit.kucheria@canonical.com>
	<a079a0627e77f2df590840e4798fc067f4436160.1259893118.git.amit.kucheria@canonical.com>
	<0559d42bc9f32e30264fea6ca6fa679121f6a241.1259893118.git.amit.kucheria@canonical.com>
	<7a49f4c0ea2f5030068729978c2cb173a6e15857.1259893118.git.amit.kucheria@canonical.com>
	<a34d2aac8d5282bfbdf09dddc2da57c4ad7da355.1259893118.git.amit.kucheria@canonical.com>
	<dbab65547b41b82719df19067b50db9c82eeb6d6.1259893118.git.amit.kucheria@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Dinh.Nguyen@freescale.com, netdev@vger.kernel.org, s.hauer@pengutronix.de,
	grant.likely@secretlab.ca, r.herring@freescale.com,
	valentin.longchamp@epfl.ch, daniel@caiaq.de,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: List Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <dbab65547b41b82719df19067b50db9c82eeb6d6.1259893118.git.amit.kucheria@canonical.com>
In-Reply-To: <cover.1259893118.git.amit.kucheria@canonical.com>
References: <cover.1259893118.git.amit.kucheria@canonical.com>
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

i.MX51 babbage board has a FEC ethernet controller

Signed-off-by: Amit Kucheria <amit.kucheria@canonical.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---
 drivers/net/Kconfig |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index b2f71f7..328112b 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1883,7 +1883,8 @@ config 68360_ENET
 
 config FEC
 	bool "FEC ethernet controller (of ColdFire and some i.MX CPUs)"
-	depends on M523x || M527x || M5272 || M528x || M520x || M532x || MACH_MX27 || ARCH_MX35 || ARCH_MX25
+	depends on M523x || M527x || M5272 || M528x || M520x || M532x || \
+		MACH_MX27 || ARCH_MX35 || ARCH_MX25 || ARCH_MX5
 	help
 	  Say Y here if you want to use the built-in 10/100 Fast ethernet
 	  controller on some Motorola ColdFire and Freescale i.MX processors.
-- 
1.6.3.3
