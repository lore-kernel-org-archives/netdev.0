From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] Fix comment for packets without data
Date: Thu, 13 Dec 2012 10:51:22 -0800
Message-ID: <50CA23AA.1040501@hp.com>
References: <1355423248-12448-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1355423248-12448-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/13/2012 10:27 AM, Florent Fourcot wrote:
> The double negation is probably a typo error
>
> Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
> ---
>   net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |    2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
> index 00ee17c..d9efe32 100644
> --- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
> +++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
> @@ -81,7 +81,7 @@ static int ipv6_get_l4proto(const struct sk_buff *skb, unsigned int nhoff,
>   	}
>   	protoff = ipv6_skip_exthdr(skb, extoff, &nexthdr, &frag_off);
>   	/*
> -	 * (protoff == skb->len) mean that the packet doesn't have no data
> +	 * (protoff == skb->len) mean that the packet does not have any data
>   	 * except of IPv6 & ext headers. but it's tracked anyway. - YK
>   	 */
>   	if (protoff < 0 || (frag_off & htons(~0x7)) != 0) {
>

Might as well take it to completion and have it read "(protoff == 
skb->len) means the packet does not have any data"  or "(protoff == 
skb->len) means the packet has no data"  Not sure about that next line 
with the except.  Perhaps "(protoff == skb->len) means the packet has no 
data, just IPv6 and extension headers, but it is tracked anyway."

rick jones
