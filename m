From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: fix possible ZERO_SIZE_PTR
 pointerdereferencing error.
Date: Wed, 1 Jun 2016 13:04:25 +0200
Message-ID: <20160601110425.GA8276@salvia>
References: <1464770068-7508-1-git-send-email-lixiubo@cmss.chinamobile.com>
 <20160601092711.GB2711@salvia>
 <574EB07B.3060307@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, kadlec@blackhole.kfki.hu, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org
To: Xiubo Li <lixiubo@cmss.chinamobile.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <574EB07B.3060307@cmss.chinamobile.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 01, 2016 at 05:52:59PM +0800, Xiubo Li wrote:
> >>  net/netfilter/x_tables.c | 3 +++
> >>  1 file changed, 3 insertions(+)
> >>
> >>diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
> >>index c8a0b7d..4df8e38 100644
> >>--- a/net/netfilter/x_tables.c
> >>+++ b/net/netfilter/x_tables.c
> >>@@ -1185,6 +1185,9 @@ struct nf_hook_ops *xt_hook_link(const struct xt_table *table, nf_hookfn *fn)
> >
> >What kernel version are you using? I don't see xt_hook_link() in the
> >development tree.
> 
> Sorry, in the wrong tree, i just work on linux-next tree, forget to checkout
> the newest tags.
> 
> Should I will use nf.git tree or others instead ?

Yes please, thanks.
