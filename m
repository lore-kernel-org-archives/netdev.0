From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] ipv6: fix RFC5722 comment
Date: Mon, 30 Jan 2012 15:42:25 +0100
Message-ID: <4F26AC51.8080108@6wind.com>
References: <1327933764.2288.42.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51962 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752605Ab2A3Om2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 09:42:28 -0500
Received: by wgbed3 with SMTP id ed3so4704450wgb.1
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2012 06:42:27 -0800 (PST)
In-Reply-To: <1327933764.2288.42.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 30/01/2012 15:29, Eric Dumazet a =C3=A9crit :
> RFC5722 Section 4 was amended by Errata 3089
>
> Our implementation did the right thing anyway...
>
> Signed-off-by: Eric Dumazet<eric.dumazet@gmail.com>
> Cc: Nicolas Dichtel<nicolas.dichtel@6wind.com>

Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>   net/ipv6/reassembly.c |    7 +++----
>   1 file changed, 3 insertions(+), 4 deletions(-)
>
> diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
> index b69fae7..9447bd6 100644
> --- a/net/ipv6/reassembly.c
> +++ b/net/ipv6/reassembly.c
> @@ -336,12 +336,11 @@ static int ip6_frag_queue(struct frag_queue *fq=
, struct sk_buff *skb,
>   	}
>
>   found:
> -	/* RFC5722, Section 4:
> -	 *                                  When reassembling an IPv6 datag=
ram, if
> +	/* RFC5722, Section 4, amended by Errata ID : 3089
> +	 *                          When reassembling an IPv6 datagram, if
Identation was an exact copy of the original rfc (not changed by the er=
rata),=20
but it's a detail ;-)


Regards,
Nicolas

>   	 *   one or more its constituent fragments is determined to be an
>   	 *   overlapping fragment, the entire datagram (and any constituen=
t
> -	 *   fragments, including those not yet received) MUST be silently
> -	 *   discarded.
> +	 *   fragments) MUST be silently discarded.
>   	 */
>
>   	/* Check for overlap with preceding fragment. */
