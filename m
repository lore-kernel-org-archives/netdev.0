From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [NF+IPsec 3/6]: IPsec output hooks
Date: Mon, 17 Oct 2005 09:37:24 +0900 (JST)
Message-ID: <20051017.093724.14937255.yoshfuji@linux-ipv6.org>
References: <4352EEC0.9050507@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	herbert@gondor.apana.org.au
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: kaber@trash.net
In-Reply-To: <4352EEC0.9050507@trash.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

In article <4352EEC0.9050507@trash.net> (at Mon, 17 Oct 2005 02:22:24 +0200), Patrick McHardy <kaber@trash.net> says:

> diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
> --- a/net/ipv6/ip6_input.c
> +++ b/net/ipv6/ip6_input.c
> @@ -250,9 +250,9 @@ int ip6_mc_input(struct sk_buff *skb)
>  			
>  			if (deliver) {
>  				skb2 = skb_clone(skb, GFP_ATOMIC);
> -				dst_output(skb2);
> +				ip_dst_output(skb2);
>  			} else {
> -				dst_output(skb);
> +				ip_dst_output(skb);
>  				return 0;
>  			}
>  		}

ip6_dst_output()?

--yoshfuji
