From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [Patch net] udp: remove a useless initialization
Date: Tue, 7 May 2013 21:17:02 -0700
Message-ID: <CALnjE+oh7JpDYDn6ju3Pr8Qh_EA-9uEK08G3mUO-z-VLbOxVGw@mail.gmail.com>
References: <1367982246-10730-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog101.obsmtp.com ([74.125.149.67]:43070 "HELO
	na3sys009aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750815Ab3EHERD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 May 2013 00:17:03 -0400
Received: by mail-qa0-f53.google.com with SMTP id f11so825714qae.19
        for <netdev@vger.kernel.org>; Tue, 07 May 2013 21:17:02 -0700 (PDT)
In-Reply-To: <1367982246-10730-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 7, 2013 at 8:04 PM, Cong Wang <amwang@redhat.com> wrote:
> 'inner_eth' is not used until it is assigned with the same
> value later.
>
since you are at this code, can you also pull inner ether header?

Thanks,
Pravin.
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Pravin B Shelar <pshelar@nicira.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
>
> ---
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 0ae038a..3d036bdd 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -2311,7 +2311,7 @@ static struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
>         struct sk_buff *segs = ERR_PTR(-EINVAL);
>         int mac_len = skb->mac_len;
>         int tnl_hlen = skb_inner_mac_header(skb) - skb_transport_header(skb);
> -       struct ethhdr *inner_eth = (struct ethhdr *)skb_inner_mac_header(skb);
> +       struct ethhdr *inner_eth;
>         __be16 protocol = skb->protocol;
>         netdev_features_t enc_features;
>         int outer_hlen;
