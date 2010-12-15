From: Vladislav Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] sctp: fix the return value of getting the sctp partial
 delivery point
Date: Wed, 15 Dec 2010 10:53:14 -0500
Message-ID: <4D08E46A.5010703@hp.com>
References: <4D0823A1.6080307@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-sctp@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:25704 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752076Ab0LOPxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 10:53:20 -0500
In-Reply-To: <4D0823A1.6080307@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/14/2010 09:10 PM, Wei Yongjun wrote:
> Get the sctp partial delivery point using SCTP_PARTIAL_DELIVERY_POINT
> socket option should return 0 if success, not -ENOTSUPP.
> 

Ack.

-vlad

> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> ---
>  net/sctp/socket.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 1bc5203..8628e8e 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -5050,7 +5050,7 @@ static int sctp_getsockopt_partial_delivery_point(struct sock *sk, int len,
>  	if (copy_to_user(optval, &val, len))
>  		return -EFAULT;
>  
> -	return -ENOTSUPP;
> +	return 0;
>  }
>  
>  /*

