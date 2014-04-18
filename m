From: "Luis R. Rodriguez" <mcgrof-3uybbJdB1yH774rrrx3eTA@public.gmane.org>
Subject: [PATCH 2/3] 6lowpan: make lowpan_cb static
Date: Thu, 17 Apr 2014 18:22:55 -0700
Message-ID: <1397784176-15809-3-git-send-email-mcgrof@do-not-panic.com>
References: <1397784176-15809-1-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, backports-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1397784176-15809-1-git-send-email-mcgrof-3uybbJdB1yH774rrrx3eTA@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Luis R. Rodriguez" <mcgrof-IBi9RG/b67k@public.gmane.org>

CC: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Signed-off-by: Luis R. Rodriguez <mcgrof-IBi9RG/b67k@public.gmane.org>
---
 net/ieee802154/reassembly.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ieee802154/reassembly.c b/net/ieee802154/reassembly.c
index 132b65b..6f1428c 100644
--- a/net/ieee802154/reassembly.c
+++ b/net/ieee802154/reassembly.c
@@ -36,7 +36,7 @@ struct lowpan_frag_info {
 	u8 d_offset;
 };
 
-struct lowpan_frag_info *lowpan_cb(struct sk_buff *skb)
+static struct lowpan_frag_info *lowpan_cb(struct sk_buff *skb)
 {
 	return (struct lowpan_frag_info *)skb->cb;
 }
-- 
1.9.1


------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/NeoTech
