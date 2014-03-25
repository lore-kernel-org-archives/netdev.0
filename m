From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 3/3] ipv6: fix checkpatch errors of foo
Date: Tue, 25 Mar 2014 20:37:58 +0300
Message-ID: <5331BEF6.5030900@cogentembedded.com>
References: <1395715493-5312-1-git-send-email-wangyufen@huawei.com> <1395715493-5312-4-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Wangyufen <wangyufen@huawei.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:60760 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753915AbaCYQiC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 12:38:02 -0400
Received: by mail-la0-f54.google.com with SMTP id mc6so586412lab.13
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 09:38:01 -0700 (PDT)
In-Reply-To: <1395715493-5312-4-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/25/2014 05:44 AM, Wangyufen wrote:

> From: Wang Yufen <wangyufen@huawei.com>

> ERROR: "(foo*)" should be "(foo *)"
> ERROR: "foo * bar" should be "foo *bar"

> Signed-off-by: Wang Yufen <wangyufen@huawei.com>
> ---
>   net/ipv6/ip6_fib.c | 18 +++++++++---------
>   1 file changed, 9 insertions(+), 9 deletions(-)

> diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
> index 8cb6949..22acde8 100644
> --- a/net/ipv6/ip6_fib.c
> +++ b/net/ipv6/ip6_fib.c
[...]
> @@ -951,7 +951,7 @@ struct lookup_args {
>   	const struct in6_addr	*addr;		/* search key			*/
>   };
>
> -static struct fib6_node * fib6_lookup_1(struct fib6_node *root,
> +static struct fib6_node *fib6_lookup_1(struct fib6_node *root,
>   					struct lookup_args *args)

    Reindent the above line please, so that it still starts under *struct* on 
the previous line.

[...]
> @@ -1014,7 +1014,7 @@ backtrack:
>   	return NULL;
>   }
>
> -struct fib6_node * fib6_lookup(struct fib6_node *root, const struct in6_addr *daddr,
> +struct fib6_node *fib6_lookup(struct fib6_node *root, const struct in6_addr *daddr,
>   			       const struct in6_addr *saddr)

    Likewise.

[...]
> @@ -1047,7 +1047,7 @@ struct fib6_node * fib6_lookup(struct fib6_node *root, const struct in6_addr *da
>    */
>
>
> -static struct fib6_node * fib6_locate_1(struct fib6_node *root,
> +static struct fib6_node *fib6_locate_1(struct fib6_node *root,
>   					const struct in6_addr *addr,
>   					int plen, int offset)

    Likewise.

[...]
> @@ -1077,7 +1077,7 @@ static struct fib6_node * fib6_locate_1(struct fib6_node *root,
>   	return NULL;
>   }
>
> -struct fib6_node * fib6_locate(struct fib6_node *root,
> +struct fib6_node *fib6_locate(struct fib6_node *root,
>   			       const struct in6_addr *daddr, int dst_len,
>   			       const struct in6_addr *saddr, int src_len)

    Likewise.

WBR, Sergei
