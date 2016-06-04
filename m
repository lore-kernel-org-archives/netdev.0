From: David Miller <davem@davemloft.net>
Subject: Re: [net-next:master 17/24] DockBook: net/core/skbuff.c:4404:
 warning: No description found for parameter 'mtu'
Date: Fri, 03 Jun 2016 22:57:02 -0700 (PDT)
Message-ID: <20160603.225702.1041264232859054469.davem@davemloft.net>
References: <201606040815.Lov0U6ON%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, netdev@vger.kernel.org,
	marcelo.leitner@gmail.com
To: fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45625 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750718AbcFDF5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jun 2016 01:57:03 -0400
In-Reply-To: <201606040815.Lov0U6ON%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kbuild test robot <fengguang.wu@intel.com>
Date: Sat, 4 Jun 2016 08:48:17 +0800

> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> head:   330348d94223346f855357fab2517f6c903001c7
> commit: ae7ef81ef000adeee7a87585b9135ff8a8064acc [17/24] skbuff: introduce skb_gso_validate_mtu
> reproduce: make htmldocs
> 
> All warnings (new ones prefixed by >>):
> 
>    include/linux/skbuff.h:928: warning: No description found for parameter 'sk'
>    include/net/sock.h:449: warning: No description found for parameter 'sk_padding'
>    include/net/sock.h:449: warning: No description found for parameter 'sk_rcu'
>>> net/core/skbuff.c:4404: warning: No description found for parameter 'mtu'
>    net/core/gen_stats.c:65: warning: No description found for parameter 'padattr'
>    net/core/gen_stats.c:100: warning: No description found for parameter 'padattr'

Fixed as follows:

====================
net: Add docbook description for 'mtu' arg to skb_gso_validate_mtu()

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/skbuff.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index b6e0f95..e7ec6d3 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4399,6 +4399,7 @@ EXPORT_SYMBOL_GPL(skb_gso_transport_seglen);
  * skb_gso_validate_mtu - Return in case such skb fits a given MTU
  *
  * @skb: GSO skb
+ * @mtu: MTU to validate against
  *
  * skb_gso_validate_mtu validates if a given skb will fit a wanted MTU
  * once split.
-- 
2.1.0
