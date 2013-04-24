From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v3] net: ipv4: typo issue, remove erroneous semicolon
Date: Wed, 24 Apr 2013 11:09:57 -0700
Message-ID: <CALnjE+oXUz8rOHuX1rqw5t3yGUsGfaO3QyoHFpmq75bwqLeJcQ@mail.gmail.com>
References: <517549F4.7030806@cogentembedded.com>
	<5175DFF9.4040000@asianux.com>
	<5175F5C3.8060503@asianux.com>
	<20130423.011604.1061769362231812796.davem@davemloft.net>
	<51762E16.703@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	sergei.shtylyov@cogentembedded.com, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org
To: Chen Gang <gang.chen@asianux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog116.obsmtp.com ([74.125.149.240]:51816 "HELO
	na3sys009aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756385Ab3DXSJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 14:09:59 -0400
Received: by mail-qe0-f72.google.com with SMTP id 1so4083995qee.3
        for <netdev@vger.kernel.org>; Wed, 24 Apr 2013 11:09:58 -0700 (PDT)
In-Reply-To: <51762E16.703@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 22, 2013 at 11:45 PM, Chen Gang <gang.chen@asianux.com> wrote:
>
> Need remove erroneous semicolon, which is found by EXTRA_CFLAGS=-W,
> the related commit number: c54419321455631079c7d6e60bc732dd0c5914c5
> ("GRE: Refactor GRE tunneling code")
>
>
> Signed-off-by: Chen Gang <gang.chen@asianux.com>
Thanks for fixing it.

Acked-by: Pravin B Shelar <pshelar@nicira.com>

> ---
>  net/ipv4/ip_gre.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index 987a4e5..c625e4d 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -444,7 +444,7 @@ static netdev_tx_t ipgre_xmit(struct sk_buff *skb,
>         if (dev->header_ops) {
>                 /* Need space for new headers */
>                 if (skb_cow_head(skb, dev->needed_headroom -
> -                                     (tunnel->hlen + sizeof(struct iphdr))));
> +                                     (tunnel->hlen + sizeof(struct iphdr))))
>                         goto free_skb;
>
>                 tnl_params = (const struct iphdr *)skb->data;
> --
> 1.7.7.6
