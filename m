From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] netfilter: Remove the spurious \ in __ip_vs_lblc_init
Date: Tue, 20 Nov 2012 09:06:49 +0900
Message-ID: <20121120000649.GC13829@verge.net.au>
References: <87zk2d7gwp.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:45888 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752541Ab2KTAGx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 19:06:53 -0500
Content-Disposition: inline
In-Reply-To: <87zk2d7gwp.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 19, 2012 at 07:26:30AM -0800, Eric W. Biederman wrote:
> 
> In (464dc801c76a net: Don't export sysctls to unprivileged users)
> I typoed and introduced a spurious backslash.  Delete it.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Signed-off-by: Simon Horman <horms@verge.net.au>

Pablo, can you take this directly through your tree?

> ---
>  net/netfilter/ipvs/ip_vs_lblc.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
> index d742aa9..fdd89b9 100644
> --- a/net/netfilter/ipvs/ip_vs_lblc.c
> +++ b/net/netfilter/ipvs/ip_vs_lblc.c
> @@ -574,7 +574,7 @@ static int __net_init __ip_vs_lblc_init(struct net *net)
>  		register_net_sysctl(net, "net/ipv4/vs", ipvs->lblc_ctl_table);
>  	if (!ipvs->lblc_ctl_header) {
>  		if (!net_eq(net, &init_net))
> -			kfree(ipvs->lblc_ctl_table);\
> +			kfree(ipvs->lblc_ctl_table);
>  		return -ENOMEM;
>  	}
>  
> -- 
> 1.7.5.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
