From: Roland Dreier <roland@topspin.com>
Subject: [PATCH][v5][3/24] Hook up drivers/infiniband
Date: Mon, 27 Dec 2004 21:50:55 -0800
Message-ID: <200412272150.BzlME8aULSGdgnS3@topspin.com>
References: <200412272150.vKuRYXlCFl5x8NAo@topspin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
In-Reply-To: <200412272150.vKuRYXlCFl5x8NAo@topspin.com>
To: davem@davemloft.net
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

Add the appropriate lines to drivers/Kconfig and drivers/Makefile so
that the kernel configuration and build systems know about drivers/infiniband.

Signed-off-by: Roland Dreier <roland@topspin.com>


--- linux-bk.orig/drivers/Kconfig	2004-12-27 21:47:59.198084242 -0800
+++ linux-bk/drivers/Kconfig	2004-12-27 21:48:19.194140917 -0800
@@ -56,4 +56,6 @@
 
 source "drivers/mmc/Kconfig"
 
+source "drivers/infiniband/Kconfig"
+
 endmenu
--- linux-bk.orig/drivers/Makefile	2004-12-27 21:48:10.314447971 -0800
+++ linux-bk/drivers/Makefile	2004-12-27 21:48:19.194140917 -0800
@@ -59,5 +59,6 @@
 obj-$(CONFIG_EISA)		+= eisa/
 obj-$(CONFIG_CPU_FREQ)		+= cpufreq/
 obj-$(CONFIG_MMC)		+= mmc/
+obj-$(CONFIG_INFINIBAND)	+= infiniband/
 obj-y				+= firmware/
 obj-$(CONFIG_CRYPTO)		+= crypto/
