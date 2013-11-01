From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/4] xfrm: use vmalloc_node() for percpu scratches
Date: Fri, 01 Nov 2013 17:02:51 +0400
Message-ID: <5273A67B.9070901@cogentembedded.com>
References: <1383292257-4634-1-git-send-email-steffen.klassert@secunet.com> <1383292257-4634-2-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:63548 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751479Ab3KANC4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Nov 2013 09:02:56 -0400
Received: by mail-la0-f47.google.com with SMTP id ep20so3319045lab.20
        for <netdev@vger.kernel.org>; Fri, 01 Nov 2013 06:02:55 -0700 (PDT)
In-Reply-To: <1383292257-4634-2-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 01-11-2013 11:50, Steffen Klassert wrote:

> From: Eric Dumazet <edumazet@google.com>

> scratches are per cpu, we can use vmalloc_node() for proper
> NUMA affinity.

> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>   net/xfrm/xfrm_ipcomp.c |    6 ++++--
>   1 file changed, 4 insertions(+), 2 deletions(-)

> diff --git a/net/xfrm/xfrm_ipcomp.c b/net/xfrm/xfrm_ipcomp.c
> index 2906d52..b943c7f 100644
> --- a/net/xfrm/xfrm_ipcomp.c
> +++ b/net/xfrm/xfrm_ipcomp.c
> @@ -220,8 +220,8 @@ static void ipcomp_free_scratches(void)
>
>   static void * __percpu *ipcomp_alloc_scratches(void)
>   {
> -	int i;
>   	void * __percpu *scratches;
> +	int i;

    This collateral change is not described in the changelog.

WBR, Sergei
