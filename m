From: Wang Weidong <wangweidong1@huawei.com>
Subject: Re: [PATCH net-next 2/3] sctp: remove the never used 'return' and,
 redundant 'break'
Date: Wed, 18 Dec 2013 17:38:29 +0800
Message-ID: <52B16D15.2010501@huawei.com>
References: <52B168E0.1060108@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-sctp@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:28141 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750910Ab3LRJj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 04:39:27 -0500
In-Reply-To: <52B168E0.1060108@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/18 17:20, Wang Weidong wrote:
> In switch() had do return, and never use the 'return NULL'. The
> 'break' after return or goto has no effect. Remove it.
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
> ---
>  net/sctp/input.c | 5 -----
>  1 file changed, 5 deletions(-)
> 
> diff --git a/net/sctp/input.c b/net/sctp/input.c
> index 2a192a7..c956dc9 100644
> --- a/net/sctp/input.c
> +++ b/net/sctp/input.c
> @@ -1120,15 +1120,10 @@ static struct sctp_association *__sctp_rcv_lookup_harder(struct net *net,
>  	case SCTP_CID_INIT:
>  	case SCTP_CID_INIT_ACK:
>  		return __sctp_rcv_init_lookup(net, skb, laddr, transportp);
> -		break;
>  
>  	default:
>  		return __sctp_rcv_walk_lookup(net, skb, laddr, transportp);
> -		break;
>  	}
> -
> -
> -	return NULL;
>  }
>  
>  /* Lookup an association for an inbound skb. */
> 

Sorry for sending the Subject "[PATCH net-next 2/3] ...".
It is only one patch, not series.

Regards.
Wang
