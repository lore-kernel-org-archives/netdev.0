From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH 1/1] ipv6: missed namespace context in ipv6_rthdr_rcv
Date: Thu, 10 Jul 2008 14:55:57 +0200
Message-ID: <487606DD.8000804@fr.ibm.com>
References: <1215691748-17151-1-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, benjamin.thery@bull.net,
	"Denis V. Lunev" <den@parallels.com>
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:31143 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753827AbYGJM4T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 08:56:19 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id m6ACu1If232328
	for <netdev@vger.kernel.org>; Thu, 10 Jul 2008 12:56:01 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6ACu1LD1105954
	for <netdev@vger.kernel.org>; Thu, 10 Jul 2008 14:56:01 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6ACu0tj023204
	for <netdev@vger.kernel.org>; Thu, 10 Jul 2008 14:56:01 +0200
In-Reply-To: <1215691748-17151-1-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denis V. Lunev wrote:
> Signed-off-by: Denis V. Lunev <den@parallels.com>
> ---
>  net/ipv6/exthdrs.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
> index 3cd1c99..dcf94fd 100644
> --- a/net/ipv6/exthdrs.c
> +++ b/net/ipv6/exthdrs.c
> @@ -445,7 +445,7 @@ looped_back:
>  			kfree_skb(skb);
>  			return -1;
>  		}
> -		if (!ipv6_chk_home_addr(&init_net, addr)) {
> +		if (!ipv6_chk_home_addr(dev_net(skb->dst->dev), addr)) {
>  			IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
>  					 IPSTATS_MIB_INADDRERRORS);
>  			kfree_skb(skb);

Thanks Denis :)
