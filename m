From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] Fix comment for packets without data
Date: Fri, 14 Dec 2012 13:28:54 -0800
Message-ID: <50CB9A16.1090006@hp.com>
References: <50CA23AA.1040501@hp.com> <1355482413-18629-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1355482413-18629-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/14/2012 02:53 AM, Florent Fourcot wrote:
> Remove ambiguity of double negation
>
> Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
> ---
>   net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |    4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
> index 00ee17c..137e245 100644
> --- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
> +++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
> @@ -81,8 +81,8 @@ static int ipv6_get_l4proto(const struct sk_buff *skb, unsigned int nhoff,
>   	}
>   	protoff = ipv6_skip_exthdr(skb, extoff, &nexthdr, &frag_off);
>   	/*
> -	 * (protoff == skb->len) mean that the packet doesn't have no data
> -	 * except of IPv6 & ext headers. but it's tracked anyway. - YK
> +	 * (protoff == skb->len) means the packet has not data, just
> +	 * IPv6 and possibly extensions headers, but it is tracked anyway
>   	 */
>   	if (protoff < 0 || (frag_off & htons(~0x7)) != 0) {
>   		pr_debug("ip6_conntrack_core: can't find proto in pkt\n");
>

Acked-by: Rick Jones <rick.jones2@hp.com>

rick
