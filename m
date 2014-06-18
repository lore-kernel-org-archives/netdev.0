From: Varka Bhadram <varkabhadram-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next v4 2/3] ieee802154: cc2520:
	add driver to kernel build system
Date: Wed, 18 Jun 2014 19:36:42 +0530
Message-ID: <1403100403-6429-3-git-send-email-varkab@cdac.in>
References: <1403100403-6429-1-git-send-email-varkab@cdac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Varka Bhadram <varkab-If5XQcfNmg0@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1403100403-6429-1-git-send-email-varkab-If5XQcfNmg0@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Varka Bhadram <varkab-If5XQcfNmg0@public.gmane.org>
---
 drivers/net/ieee802154/Kconfig  |   11 +++++++++++
 drivers/net/ieee802154/Makefile |    1 +
 2 files changed, 12 insertions(+)

diff --git a/drivers/net/ieee802154/Kconfig b/drivers/net/ieee802154/Kconfig
index 3e89bea..8b7ae51 100644
--- a/drivers/net/ieee802154/Kconfig
+++ b/drivers/net/ieee802154/Kconfig
@@ -51,3 +51,14 @@ config IEEE802154_MRF24J40
 
 	  This driver can also be built as a module. To do so, say M here.
 	  the module will be called 'mrf24j40'.
+
+config IEEE802154_CC2520
+	depends on IEEE802154_DRIVERS && MAC802154
+	tristate "CC2520 transceiver driver"
+	depends on SPI
+	---help---
+	  Say Y here to enable the CC2520 SPI 802.15.4 wireless
+	  controller.
+
+	  This driver can also be built as a module. To do so, say M here.
+	  the module will be called 'cc2520'.
diff --git a/drivers/net/ieee802154/Makefile b/drivers/net/ieee802154/Makefile
index abb0c08..655cb95 100644
--- a/drivers/net/ieee802154/Makefile
+++ b/drivers/net/ieee802154/Makefile
@@ -2,3 +2,4 @@ obj-$(CONFIG_IEEE802154_FAKEHARD) += fakehard.o
 obj-$(CONFIG_IEEE802154_FAKELB) += fakelb.o
 obj-$(CONFIG_IEEE802154_AT86RF230) += at86rf230.o
 obj-$(CONFIG_IEEE802154_MRF24J40) += mrf24j40.o
+obj-$(CONFIG_IEEE802154_CC2520) += cc2520.o
-- 
1.7.9.5


------------------------------------------------------------------------------
HPCC Systems Open Source Big Data Platform from LexisNexis Risk Solutions
Find What Matters Most in Your Big Data with HPCC Systems
Open Source. Fast. Scalable. Simple. Ideal for Dirty Data.
Leverages Graph Analysis for Fast Processing & Easy Data Exploration
http://p.sf.net/sfu/hpccsystems
