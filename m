From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next v5 5/8] 6lowpan: move
	6lowpan.c to 6lowpan_rtnl.c
Date: Thu, 27 Feb 2014 09:06:19 +0100
Message-ID: <1393488382-1250-6-git-send-email-alex.aring@gmail.com>
References: <1393488382-1250-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1393488382-1250-1-git-send-email-alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

We have a 6lowpan.c file and 6lowpan.ko file. To avoid confusing we
should move 6lowpan.c to 6lowpan_rtnl.c. Then we can support multiple
source files for 6lowpan module.

Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/ieee802154/{6lowpan.c => 6lowpan_rtnl.c} | 0
 net/ieee802154/Makefile                      | 1 +
 2 files changed, 1 insertion(+)
 rename net/ieee802154/{6lowpan.c => 6lowpan_rtnl.c} (100%)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan_rtnl.c
similarity index 100%
rename from net/ieee802154/6lowpan.c
rename to net/ieee802154/6lowpan_rtnl.c
diff --git a/net/ieee802154/Makefile b/net/ieee802154/Makefile
index e8f0588..3d08adf 100644
--- a/net/ieee802154/Makefile
+++ b/net/ieee802154/Makefile
@@ -2,5 +2,6 @@ obj-$(CONFIG_IEEE802154) += ieee802154.o af_802154.o
 obj-$(CONFIG_IEEE802154_6LOWPAN) += 6lowpan.o
 obj-$(CONFIG_6LOWPAN_IPHC) += 6lowpan_iphc.o
 
+6lowpan-y := 6lowpan_rtnl.o
 ieee802154-y := netlink.o nl-mac.o nl-phy.o nl_policy.o wpan-class.o
 af_802154-y := af_ieee802154.o raw.o dgram.o
-- 
1.9.0


------------------------------------------------------------------------------
Flow-based real-time traffic analytics software. Cisco certified tool.
Monitor traffic, SLAs, QoS, Medianet, WAAS etc. with NetFlow Analyzer
Customize your own dashboards, set traffic alerts and generate reports.
Network behavioral analysis & security monitoring. All-in-one tool.
http://pubads.g.doubleclick.net/gampad/clk?id=126839071&iu=/4140/ostg.clktrk
