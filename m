From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Introducing socket mark socket option
Date: Wed, 23 Jan 2008 15:19:51 +0100
Message-ID: <47974D07.5040202@trash.net>
References: <12010920051270-git-send-email-panther@balabit.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-arch@vger.kernel.org
To: Laszlo Attila Toth <panther@balabit.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <12010920051270-git-send-email-panther@balabit.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Laszlo Attila Toth wrote:
> A userspace program may wish to set the mark for each packets its send
> without using the netfilter MARK target. Changing the mark can be used
> mark based routing without netfilter or for packet filtering.
> 
> It requires CAP_NET_ADMIN capability.
> 

> @@ -403,6 +403,7 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
>  					      { .daddr = daddr,
>  						.saddr = rt->rt_spec_dst,
>  						.tos = RT_TOS(ip_hdr(skb)->tos) } },
> +				    .mark = sk->sk_mark,

This is useless, the icmp socket is not visible to userspace.

> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
 > ...

What about IPv6?
