From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: nf_nat_snmp_basic: fix duplicates in if/else branches
Date: Tue, 11 Feb 2014 16:11:02 +0000
Message-ID: <ff58928d-2f4e-4572-a8c3-71a0ce1844c9@email.android.com>
References: <1392130165-4313-1-git-send-email-fx.lebail@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
To: Francois-Xavier Le Bail <fx.lebail@yahoo.com>,
	NETDEV <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <1392130165-4313-1-git-send-email-fx.lebail@yahoo.com>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11. Februar 2014 14:49:25 GMT+00:00, Francois-Xavier Le Bail <fx.lebail@yahoo.com> wrote:
>The solution was found by Patrick in 2.4 kernel sources.
>
>Cc: Patrick McHardy <kaber@trash.net>

Acked-by: Patrick McHardy <kaber@trash.net>

>Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
>---
> net/ipv4/netfilter/nf_nat_snmp_basic.c |    4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
>
>diff --git a/net/ipv4/netfilter/nf_nat_snmp_basic.c
>b/net/ipv4/netfilter/nf_nat_snmp_basic.c
>index d551e31..7c67667 100644
>--- a/net/ipv4/netfilter/nf_nat_snmp_basic.c
>+++ b/net/ipv4/netfilter/nf_nat_snmp_basic.c
>@@ -1198,8 +1198,8 @@ static int snmp_translate(struct nf_conn *ct,
> 		map.to = NOCT1(&ct->tuplehash[!dir].tuple.dst.u3.ip);
> 	} else {
> 		/* DNAT replies */
>-		map.from = NOCT1(&ct->tuplehash[dir].tuple.src.u3.ip);
>-		map.to = NOCT1(&ct->tuplehash[!dir].tuple.dst.u3.ip);
>+		map.from = NOCT1(&ct->tuplehash[!dir].tuple.src.u3.ip);
>+		map.to = NOCT1(&ct->tuplehash[dir].tuple.dst.u3.ip);
> 	}
> 
> 	if (map.from == map.to)
>--
>To unsubscribe from this list: send the line "unsubscribe
>netfilter-devel" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html


