From: Li RongQing <roy.qing.li@gmail.com>
Subject: Re: [PATCH] netpoll: fix the skb check in pkt_is_ns
Date: Tue, 18 Mar 2014 08:05:29 +0800
Message-ID: <CAJFZqHy1UZjn7+CjmODMPuNWKDQhEW_Fg9ckaGC1LYh7iU6odw@mail.gmail.com>
References: <1395046419-29114-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f171.google.com ([209.85.216.171]:57447 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752591AbaCRAFa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 20:05:30 -0400
Received: by mail-qc0-f171.google.com with SMTP id c9so1080673qcz.30
        for <netdev@vger.kernel.org>; Mon, 17 Mar 2014 17:05:29 -0700 (PDT)
In-Reply-To: <1395046419-29114-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

this patch can be dropped since other patch has been merged into
net-next[netpoll: Remove dead packet receive code
(CONFIG_NETPOLL_TRAP)]

On Mon, Mar 17, 2014 at 4:53 PM,  <roy.qing.li@gmail.com> wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
>
> Neighbor Solicitation is ipv6 protocol, so we should check
> skb->protocol with ETH_P_IPV6
>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> Cc: WANG Cong <amwang@redhat.com>
> ---
>  net/core/netpoll.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> index 570eb40..159f160 100644
> --- a/net/core/netpoll.c
> +++ b/net/core/netpoll.c
> @@ -742,7 +742,7 @@ static bool pkt_is_ns(struct sk_buff *skb)
>         struct nd_msg *msg;
>         struct ipv6hdr *hdr;
>
> -       if (skb->protocol != htons(ETH_P_ARP))
> +       if (skb->protocol != htons(ETH_P_IPV6))
>                 return false;
>         if (!pskb_may_pull(skb, sizeof(struct ipv6hdr) + sizeof(struct nd_msg)))
>                 return false;
> --
> 1.7.10.4
>
