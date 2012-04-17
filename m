From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 12/12] netfilter: export necessary function for generic
 proto
Date: Tue, 17 Apr 2012 11:01:10 +0200
Message-ID: <20120417090110.GE2100@1984>
References: <1334631383-12326-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1334631383-12326-13-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	ebiederm@xmission.com, serge.hallyn@canonical.com,
	dlezcano@fr.ibm.com
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1334631383-12326-13-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 17, 2012 at 10:56:23AM +0800, Gao feng wrote:
> export two functions nf_conntrack_proto_generic_net_init and
> nf_conntrack_proto_generic_net_fini.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> ---
>  include/net/netfilter/nf_conntrack_core.h |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/include/net/netfilter/nf_conntrack_core.h b/include/net/netfilter/nf_conntrack_core.h
> index aced085..3c3fabe 100644
> --- a/include/net/netfilter/nf_conntrack_core.h
> +++ b/include/net/netfilter/nf_conntrack_core.h
> @@ -31,6 +31,9 @@ extern void nf_conntrack_cleanup(struct net *net);
>  extern int nf_conntrack_proto_init(void);
>  extern void nf_conntrack_proto_fini(void);
>  
> +extern int nf_conntrack_proto_generic_net_init(struct net *net);
> +extern void nf_conntrack_proto_generic_net_fini(struct net *net);

This does not require a separated patch only for this.

Please, review the logic that you've follow to split changes.

Thank you.
