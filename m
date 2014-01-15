From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: Re: [PATCH net-next] netfilter: remove double colon
Date: Wed, 15 Jan 2014 22:05:31 +0400
Message-ID: <CAOJe8K1qSTH-NDhVB40e9nTth3YmV41h0V3HRv6rE1JVGZTkdg@mail.gmail.com>
References: <20140115081250.56958f9a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:42913 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752008AbaAOSFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 13:05:32 -0500
Received: by mail-ob0-f180.google.com with SMTP id wm4so1504229obc.25
        for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 10:05:31 -0800 (PST)
In-Reply-To: <20140115081250.56958f9a@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

You did miss the "---" after SOB ;)

On 1/15/14, Stephen Hemminger <stephen@networkplumber.org> wrote:
> This is C not shell script
>
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>
> --- a/net/ipv4/netfilter.c	2013-12-31 17:45:31.993942921 -0800
> +++ b/net/ipv4/netfilter.c	2014-01-15 08:10:49.793785943 -0800
> @@ -61,7 +61,7 @@ int ip_route_me_harder(struct sk_buff *s
>  		skb_dst_set(skb, NULL);
>  		dst = xfrm_lookup(net, dst, flowi4_to_flowi(&fl4), skb->sk, 0);
>  		if (IS_ERR(dst))
> -			return PTR_ERR(dst);;
> +			return PTR_ERR(dst);
>  		skb_dst_set(skb, dst);
>  	}
>  #endif
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
