From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH net-next] ipv6: Use FIELD_SIZEOF() instead of dummy variable.
Date: Thu, 10 Jan 2013 01:56:33 +0900
Message-ID: <50EDA141.7060608@linux-ipv6.org>
References: <50ED8D35.8070506@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:60681 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932251Ab3AIQ4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2013 11:56:34 -0500
In-Reply-To: <50ED8D35.8070506@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki wrote:
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> ---
>  net/ipv6/af_inet6.c |    3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
> index b043c60..6b793bf 100644
> --- a/net/ipv6/af_inet6.c
> +++ b/net/ipv6/af_inet6.c
> @@ -811,11 +811,10 @@ static struct pernet_operations inet6_net_ops = {
>  
>  static int __init inet6_init(void)
>  {
> -	struct sk_buff *dummy_skb;
>  	struct list_head *r;
>  	int err = 0;
>  
> -	BUILD_BUG_ON(sizeof(struct inet6_skb_parm) > sizeof(dummy_skb->cb));
> +	BUILD_BUG_ON(sizeof(struct inet6_skb_parm) > FIELD_SIZEOF(struct sk_buff, cb));
>  
>  	/* Register the socket-side information for inet6_create.  */
>  	for (r = &inetsw6[0]; r < &inetsw6[SOCK_MAX]; ++r)
> 

I'm resending this one with others.

--yoshfuji
