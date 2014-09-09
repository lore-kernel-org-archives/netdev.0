From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next] ipv6: udp6_gro_complete() is static
Date: Tue, 9 Sep 2014 11:30:59 -0700
Message-ID: <CA+mtBx9WA1Bff5YNP2vWUm8oaRBLNT+hsbigNau2vCrKzORTuA@mail.gmail.com>
References: <1410275777.7106.8.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:47230 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751236AbaIISbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 14:31:00 -0400
Received: by mail-ie0-f175.google.com with SMTP id at20so677639iec.34
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2014 11:30:59 -0700 (PDT)
In-Reply-To: <1410275777.7106.8.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 9, 2014 at 8:16 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> net/ipv6/udp_offload.c:159:5: warning: symbol 'udp6_gro_complete' was
> not declared. Should it be static?
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: 57c67ff4bd92 ("udp: additional GRO support")
> Cc: Tom Herbert <therbert@google.com>
> ---
>  net/ipv6/udp_offload.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
> index 89cb9a9b8537..a1ad34b1c4ec 100644
> --- a/net/ipv6/udp_offload.c
> +++ b/net/ipv6/udp_offload.c
> @@ -156,7 +156,7 @@ flush:
>         return NULL;
>  }
>
> -int udp6_gro_complete(struct sk_buff *skb, int nhoff)
> +static int udp6_gro_complete(struct sk_buff *skb, int nhoff)
>  {
>         const struct ipv6hdr *ipv6h = ipv6_hdr(skb);
>         struct udphdr *uh = (struct udphdr *)(skb->data + nhoff);
>
>
Acked-by: Tom Herbert <therbert@google.com>
