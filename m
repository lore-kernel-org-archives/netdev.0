From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] iptables: use skb->len for accounting
Date: Fri, 23 Jul 2010 14:47:17 +0800
Message-ID: <AANLkTikFp9tjtYz5c0GTOfcS1DD8v6fLvBUVVeBVbsns@mail.gmail.com>
References: <1279856088-9004-1-git-send-email-xiaosuo@gmail.com>
	<1279866541.2482.79.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1279866541.2482.79.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 23, 2010 at 2:29 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le vendredi 23 juillet 2010 =E0 11:34 +0800, Changli Gao a =E9crit :
>> iptables: use skb->len for accounting
>>
>> use skb->len for accounting as xt_quota does.
>>
>
> Why ?
>
> This is a gratuitous change, unless you have very strong arguments.
>
> xt_quota is an exception, dont change all others because of it !

exception ? Why ?

>
> It is about actual data on wire, including overhead (excess bytes aft=
er
> IP frame if any).
>
> But IP tables accounting is about IP only.
>

Is the assumption that: the packets in netfilter have the padding
bytes removed, and skb->data points to the network header? Thanks.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
