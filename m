From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next] ipv4: udp4_gro_complete() is static
Date: Tue, 9 Sep 2014 11:30:35 -0700
Message-ID: <CA+mtBx-OtXSw7rE=z1owObHUaCx49HfesuP+SM8YT63qBAXEsg@mail.gmail.com>
References: <1410276552.7106.17.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:41910 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751837AbaIISag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 14:30:36 -0400
Received: by mail-ie0-f174.google.com with SMTP id lx4so1444259iec.5
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2014 11:30:35 -0700 (PDT)
In-Reply-To: <1410276552.7106.17.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 9, 2014 at 8:29 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> net/ipv4/udp_offload.c:339:5: warning: symbol 'udp4_gro_complete' was
> not declared. Should it be static?
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Tom Herbert <therbert@google.com>
> Fixes: 57c67ff4bd92 ("udp: additional GRO support")
> ---
>  net/ipv4/udp_offload.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
> index 84e0e05c9c0e..52d5f46abf86 100644
> --- a/net/ipv4/udp_offload.c
> +++ b/net/ipv4/udp_offload.c
> @@ -336,7 +336,7 @@ int udp_gro_complete(struct sk_buff *skb, int nhoff)
>         return err;
>  }
>
> -int udp4_gro_complete(struct sk_buff *skb, int nhoff)
> +static int udp4_gro_complete(struct sk_buff *skb, int nhoff)
>  {
>         const struct iphdr *iph = ip_hdr(skb);
>         struct udphdr *uh = (struct udphdr *)(skb->data + nhoff);
>
>
Acked-by: Tom Herbert <therbert@google.com>
