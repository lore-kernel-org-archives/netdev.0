From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: [PATCH][28/37] Clean up duplicate includes in net/ipv4/
Date: Sat, 21 Jul 2007 17:03:38 +0200
Message-ID: <200707211703.38712.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Alan Cox <Alan.Cox@linux.org>, waltje@uwalt.nl.mugnet.org,
	Donald Becker <becker@super.org>,
	Harald Welte <laforge@netfilter.org>, netdev@vger.kernel.org,
	Jesper Juhl <jesper.juhl@gmail.com>, netfilter-devel@lists.netfilter.org,
	Stefan Becker <stefanb@yello.ping.de>,
	Fabio Olive Leite <olive@unixforge.org>,
	Wensong Zhang <wensong@linuxvirtualserver.org>,
	Hirokazu Takahashi <taka@valinux.co.jp>, Julian Anastasov <ja@ssi.bg>,
	Jorge Cwik <jorge@laser.satlink.net>,
	Arnt Gulbrandsen <agulbra@nvg.unit.no>, FredNvanKempen@dragon,
	Andrew Morton <akpm@linux-foundation.org>,
	David S Miller <davem@davemloft.net>, Peter Kese <peter.kese@ijs.si>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Hi,

This patch cleans up duplicate includes in
	net/ipv4/


Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
---

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index c9e2b5e..0f1d7be 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -75,7 +75,6 @@
 #include <net/icmp.h>
 #include <net/checksum.h>
 #include <net/inetpeer.h>
-#include <net/checksum.h>
 #include <linux/igmp.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/netfilter_bridge.h>
diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
index e1052bc..c32781d 100644
--- a/net/ipv4/ipvs/ip_vs_ctl.c
+++ b/net/ipv4/ipvs/ip_vs_ctl.c
@@ -29,7 +29,6 @@
 #include <linux/proc_fs.h>
 #include <linux/workqueue.h>
 #include <linux/swap.h>
-#include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 
 #include <linux/netfilter.h>
diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index dcc12b1..69bd362 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -19,7 +19,6 @@
 #include <linux/udp.h>
 #include <linux/icmp.h>
 #include <linux/if_arp.h>
-#include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/netfilter_arp.h>
 #include <linux/netfilter/x_tables.h>
