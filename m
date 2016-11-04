From: Simon Horman <horms@verge.net.au>
Subject: Re: [Patch net] ipvs: use IPVS_CMD_ATTR_MAX for family.maxattr
Date: Fri, 4 Nov 2016 11:58:44 +0100
Message-ID: <20161104105843.GC24863@verge.net.au>
References: <1478218443-11616-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
        andreyknvl@google.com, Pablo Neira Ayuso <pablo@netfilter.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:43423 "EHLO
        kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760618AbcKDK6v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 06:58:51 -0400
Content-Disposition: inline
In-Reply-To: <1478218443-11616-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 03, 2016 at 05:14:03PM -0700, Cong Wang wrote:
> family.maxattr is the max index for policy[], the size of
> ops[] is determined with ARRAY_SIZE().
> 
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Tested-by: Andrey Konovalov <andreyknvl@google.com>
> Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>


Signed-off-by: Simon Horman <horms@verge.net.au>

Pablo, can you take this one into nf?

> ---
>  net/netfilter/ipvs/ip_vs_ctl.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index c3c809b..a6e44ef 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -2845,7 +2845,7 @@ static struct genl_family ip_vs_genl_family = {
>  	.hdrsize	= 0,
>  	.name		= IPVS_GENL_NAME,
>  	.version	= IPVS_GENL_VERSION,
> -	.maxattr	= IPVS_CMD_MAX,
> +	.maxattr	= IPVS_CMD_ATTR_MAX,
>  	.netnsok        = true,         /* Make ipvsadm to work on netns */
>  };
>  
> -- 
> 2.1.0
> 
