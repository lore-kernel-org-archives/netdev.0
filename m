From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH] net: l2tp: mark expected switch fall-through
Date: Thu, 19 Oct 2017 10:51:04 +0200
Message-ID: <20171019085104.nxxtmbnd3t4rsyqj@alphalink.fr>
References: <20171017224253.GA5877@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171017224253.GA5877@embeddedor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 17, 2017 at 05:42:53PM -0500, Gustavo A. R. Silva wrote:
> This code was tested by compilation only (GCC 7.2.0 was used).
> 
No worry, this case really has to fall through.

> diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
> index 7135f46..f517942 100644
> --- a/net/l2tp/l2tp_netlink.c
> +++ b/net/l2tp/l2tp_netlink.c
> @@ -406,7 +406,7 @@ static int l2tp_nl_tunnel_send(struct sk_buff *skb, u32 portid, u32 seq, int fla
>  		if (nla_put_u16(skb, L2TP_ATTR_UDP_SPORT, ntohs(inet->inet_sport)) ||
>  		    nla_put_u16(skb, L2TP_ATTR_UDP_DPORT, ntohs(inet->inet_dport)))
>  			goto nla_put_failure;
> -		/* NOBREAK */
> +		/* fall through  */
>  	case L2TP_ENCAPTYPE_IP:
> 
Nit: extra whitespace before '*/' (just couldn't restrain myself from
noticing).

Acked-by: Guillaume Nault <g.nault@alphalink.fr>
