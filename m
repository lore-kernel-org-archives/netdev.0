From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH] fixup! net: pxa168_eth: Provide phy_interface mode on
 platform_data
Date: Sat, 25 Oct 2014 12:08:59 +0200
Message-ID: <1414231739-7447-1-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1414002412-13615-3-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, Eric Miao <eric.y.miao@gmail.com>,
 netdev@vger.kernel.org, Antoine Tenart <antoine.tenart@free-electrons.com>,
 linux-kernel@vger.kernel.org, Haojian Zhuang <haojian.zhuang@gmail.com>,
 linux-arm-kernel@lists.infradead.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
 "David S. Miller" <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1414002412-13615-3-git-send-email-sebastian.hesselbarth@gmail.com>
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

Do not add phy include to the board file but platform_data include
instead.

Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
---
David,

I should have compile tested this patch earlier. I did now on
pxa168_defconfig right after I received an 0-day kbuild error
on this patch.

This is the corresponding fix, can you please squash it in?

Thanks and sorry for the noise,

Sebastian

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>
Cc: Eric Miao <eric.y.miao@gmail.com>
Cc: Haojian Zhuang <haojian.zhuang@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 arch/arm/mach-mmp/gplugd.c | 1 -
 include/linux/pxa168_eth.h | 2 ++
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/arch/arm/mach-mmp/gplugd.c b/arch/arm/mach-mmp/gplugd.c
index 3b5794cd0357..22762a1f9f72 100644
--- a/arch/arm/mach-mmp/gplugd.c
+++ b/arch/arm/mach-mmp/gplugd.c
@@ -12,7 +12,6 @@
 #include <linux/platform_device.h>
 #include <linux/gpio.h>
 #include <linux/gpio-pxa.h>
-#include <linux/phy.h>
 
 #include <asm/mach/arch.h>
 #include <asm/mach-types.h>
diff --git a/include/linux/pxa168_eth.h b/include/linux/pxa168_eth.h
index 37c381120bc8..e1ab6e86cdb3 100644
--- a/include/linux/pxa168_eth.h
+++ b/include/linux/pxa168_eth.h
@@ -4,6 +4,8 @@
 #ifndef __LINUX_PXA168_ETH_H
 #define __LINUX_PXA168_ETH_H
 
+#include <linux/phy.h>
+
 struct pxa168_eth_platform_data {
 	int	port_number;
 	int	phy_addr;
-- 
1.9.1
