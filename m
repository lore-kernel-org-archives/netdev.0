From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH net-next] hp100: delete VG/AnyLAN hp100
Date: Thu, 17 May 2012 15:09:07 -0700
Message-ID: <1337292547.8872.20.camel@joe2Laptop>
References: <1337272841-25931-1-git-send-email-paul.gortmaker@windriver.com>
	 <1337272841-25931-3-git-send-email-paul.gortmaker@windriver.com>
	 <4FB52C99.6010303@windriver.com> <20120517212039.GC27789@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, JBottomley@parallels.com,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120517212039.GC27789@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-05-17 at 17:20 -0400, Paul Gortmaker wrote:
> [Re: [PATCH 2/5] drivers/net: delete all code/drivers depending on CONFIG_MCA

If we're removing really old and unused stuff,
how about the VG/AnyLAN driver too?
---
 drivers/net/ethernet/Kconfig     |    1 -
 drivers/net/ethernet/Makefile    |    1 -
 drivers/net/ethernet/hp/Kconfig  |   32 -
 drivers/net/ethernet/hp/Makefile |    5 -
 drivers/net/ethernet/hp/hp100.c  | 3066 --------------------------------------
 drivers/net/ethernet/hp/hp100.h  |  615 --------
 6 files changed, 0 insertions(+), 3720 deletions(-)
 delete mode 100644 drivers/net/ethernet/hp/Kconfig
 delete mode 100644 drivers/net/ethernet/hp/Makefile
 delete mode 100644 drivers/net/ethernet/hp/hp100.c
 delete mode 100644 drivers/net/ethernet/hp/hp100.h

diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index a11af5c..0896c8f 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -52,7 +52,6 @@ source "drivers/net/ethernet/neterion/Kconfig"
 source "drivers/net/ethernet/faraday/Kconfig"
 source "drivers/net/ethernet/freescale/Kconfig"
 source "drivers/net/ethernet/fujitsu/Kconfig"
-source "drivers/net/ethernet/hp/Kconfig"
 source "drivers/net/ethernet/ibm/Kconfig"
 source "drivers/net/ethernet/intel/Kconfig"
 source "drivers/net/ethernet/i825xx/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 878ad32..756ebd3 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -27,7 +27,6 @@ obj-$(CONFIG_NET_VENDOR_EXAR) += neterion/
 obj-$(CONFIG_NET_VENDOR_FARADAY) += faraday/
 obj-$(CONFIG_NET_VENDOR_FREESCALE) += freescale/
 obj-$(CONFIG_NET_VENDOR_FUJITSU) += fujitsu/
-obj-$(CONFIG_NET_VENDOR_HP) += hp/
 obj-$(CONFIG_NET_VENDOR_IBM) += ibm/
 obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
 obj-$(CONFIG_NET_VENDOR_I825XX) += i825xx/
