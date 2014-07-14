From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/4] udp: Move udp_tunnel_segment into udp_offload.c
Date: Mon, 14 Jul 2014 11:11:33 +0200
Message-ID: <1405329093.10255.0.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1407131940460.24734@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:51629 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751593AbaGNJLi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 05:11:38 -0400
Received: by mail-wi0-f169.google.com with SMTP id n3so2083699wiv.2
        for <netdev@vger.kernel.org>; Mon, 14 Jul 2014 02:11:37 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1407131940460.24734@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-07-13 at 19:49 -0700, Tom Herbert wrote:
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---

> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
> index 546d2d4..4807544 100644
> --- a/net/ipv4/udp_offload.c
> +++ b/net/ipv4/udp_offload.c
> @@ -47,6 +47,82 @@ static int udp4_ufo_send_check(struct sk_buff *skb)
>  	return 0;
>  }
>  
> +struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
> +				       netdev_features_t features)
> +{


Hmm. Looks like skb_udp_tunnel_segment() should be static then ?
