From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] ip6t_REJECT: wire up ip6t_register_target() return value
Date: Fri, 25 Aug 2006 07:07:03 +0200
Message-ID: <44EE8577.5030805@trash.net>
References: <20060825010654.GJ5204@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38540 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1422839AbWHYFHG
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 01:07:06 -0400
To: Alexey Dobriyan <adobriyan@gmail.com>
In-Reply-To: <20060825010654.GJ5204@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote:
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> ---
> 
>  net/ipv6/netfilter/ip6t_REJECT.c |    4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> --- a/net/ipv6/netfilter/ip6t_REJECT.c
> +++ b/net/ipv6/netfilter/ip6t_REJECT.c
> @@ -256,9 +256,7 @@ static struct ip6t_target ip6t_reject_re
>  
>  static int __init ip6t_reject_init(void)
>  {
> -	if (ip6t_register_target(&ip6t_reject_reg))
> -		return -EINVAL;
> -	return 0;
> +	return ip6t_register_target(&ip6t_reject_reg);
>  }

This is already changed in the net-2.6.19 tree.
