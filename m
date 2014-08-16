From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 4/4] IPV6: checkpatch corrections
Date: Sat, 16 Aug 2014 20:12:11 +0400
Message-ID: <53EF82DB.3070405@cogentembedded.com>
References: <1408190687-28941-1-git-send-email-ipm@chirality.org.uk> <1408190687-28941-4-git-send-email-ipm@chirality.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Ian Morris <ipm@chirality.org.uk>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:53134 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751528AbaHPQMP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Aug 2014 12:12:15 -0400
Received: by mail-la0-f47.google.com with SMTP id mc6so3281564lab.34
        for <netdev@vger.kernel.org>; Sat, 16 Aug 2014 09:12:13 -0700 (PDT)
In-Reply-To: <1408190687-28941-4-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 8/16/2014 4:04 PM, Ian Morris wrote:

> minor coding style changes to address checkpatch warnings
> no differences according to objdump

> Signed-off-by: Ian Morris <ipm@chirality.org.uk>
> ---
>   net/ipv6/route.c        |    3 +--
>   net/ipv6/udp.c          |    3 ++-
>   net/ipv6/xfrm6_tunnel.c |    9 ++++++---
>   3 files changed, 9 insertions(+), 6 deletions(-)

> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index f74b041..85c11d4 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -2578,8 +2578,7 @@ static int rt6_fill_node(struct net *net,
>   			rtm->rtm_type = RTN_UNREACHABLE;
>   			break;
>   		}
> -	}
> -	else if (rt->rt6i_flags & RTF_LOCAL)
> +	} else if (rt->rt6i_flags & RTF_LOCAL)
>   		rtm->rtm_type = RTN_LOCAL;
>   	else if (rt->dst.dev && (rt->dst.dev->flags & IFF_LOOPBACK))
>   		rtm->rtm_type = RTN_LOCAL;

    All arms of the *if* statement should have {} if at least one has it. High 
time to fix it.

[...]
> diff --git a/net/ipv6/xfrm6_tunnel.c b/net/ipv6/xfrm6_tunnel.c
> index 5743044..b30eeac 100644
> --- a/net/ipv6/xfrm6_tunnel.c
> +++ b/net/ipv6/xfrm6_tunnel.c
> @@ -268,9 +268,12 @@ static int xfrm6_tunnel_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
>   		break;
>   	case ICMPV6_PARAMPROB:
>   		switch (code) {
> -		case ICMPV6_HDR_FIELD: break;
> -		case ICMPV6_UNK_NEXTHDR: break;
> -		case ICMPV6_UNK_OPTION: break;
> +		case ICMPV6_HDR_FIELD:
> +			break;
> +		case ICMPV6_UNK_NEXTHDR:
> +			break;
> +		case ICMPV6_UNK_OPTION:
> +			break;

    Could reduce this to only one *break*.

WBR, Sergei
