From: Dmitry Kravkov <dkravkov@gmail.com>
Subject: Re: [PATCH net-next 5/6] ipip: add GSO/TSO support
Date: Sat, 19 Oct 2013 23:00:50 +0200
Message-ID: <CAM8tLiN4M5RhFzp0VMU7mwqOTUiL+BGJ3vZ4X-zRjBAugbRzXA@mail.gmail.com>
References: <1382208178-22347-1-git-send-email-edumazet@google.com>
	<1382208178-22347-6-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jerry Chu <hkchu@google.com>, Tom Herbert <therbert@google.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f44.google.com ([209.85.214.44]:42712 "EHLO
	mail-bk0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751432Ab3JSVAx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 17:00:53 -0400
Received: by mail-bk0-f44.google.com with SMTP id mz10so228850bkb.31
        for <netdev@vger.kernel.org>; Sat, 19 Oct 2013 14:00:51 -0700 (PDT)
In-Reply-To: <1382208178-22347-6-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
> index 55e6bfb..e5d4361 100644
> --- a/net/ipv4/gre_offload.c
> +++ b/net/ipv4/gre_offload.c
> @@ -39,7 +39,8 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
>                                   SKB_GSO_UDP |
>                                   SKB_GSO_DODGY |
>                                   SKB_GSO_TCP_ECN |
> -                                 SKB_GSO_GRE)))
> +                                 SKB_GSO_GRE |
> +                                 SKB_GSO_IPIP)))
>                 goto out;

Why GRE needs this bit?
