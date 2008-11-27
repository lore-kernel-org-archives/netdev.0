From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: netfilter 07/29: netns ebtables: ebtable_broute in netns
Date: Thu, 27 Nov 2008 19:25:57 +0100 (CET)
Message-ID: <alpine.LNX.1.10.0811271925170.21626@fbirervta.pbzchgretzou.qr>
References: <20081127161503.13891.62766.sendpatchset@x2.localnet> <20081127161512.13891.85396.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081127161512.13891.85396.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thursday 2008-11-27 17:15, Patrick McHardy wrote:

>commit 8157e6d16af86e4a8d31a035db7be02a8a171c26
>Author: Alexey Dobriyan <adobriyan@gmail.com>
>Date:   Tue Nov 4 14:29:03 2008 +0100
>
>    netfilter: netns ebtables: ebtable_broute in netns
>    
>    Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
>    Signed-off-by: Patrick McHardy <kaber@trash.net>
>
>diff --git a/include/net/netns/x_tables.h b/include/net/netns/x_tables.h
>index b809397..055e684 100644
>--- a/include/net/netns/x_tables.h
>+++ b/include/net/netns/x_tables.h
>@@ -4,7 +4,10 @@
> #include <linux/list.h>
> #include <linux/netfilter.h>
> 
>+struct ebt_table;
>+
> struct netns_xt {
> 	struct list_head tables[NFPROTO_NUMPROTO];
>+	struct ebt_table *broute_table;
> };
> #endif

Where are the other tables from ip and ip6? Wait, I think...
the ebtables definitions should go to ebtables.h, just like
the ip/ip6 ones went to [not x_tables.h].

