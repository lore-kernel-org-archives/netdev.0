From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 2/3] netpoll: add IPv6 support
Date: Thu, 03 Jan 2013 01:54:53 -0800 (PST)
Message-ID: <20130103.015453.730687035214069794.davem@davemloft.net>
References: <1357188623-15206-1-git-send-email-amwang@redhat.com>
	<1357188623-15206-2-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50065 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753046Ab3ACJyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2013 04:54:54 -0500
In-Reply-To: <1357188623-15206-2-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Thu,  3 Jan 2013 12:50:22 +0800

> -static inline int udp6_csum_init(struct sk_buff *skb, struct udphdr *uh,
> -				 int proto)
> +int udp6_csum_init(struct sk_buff *skb, struct udphdr *uh, int proto)
>  {
>  	int err;
>  
> -- 
> 1.7.7.6
> 

With IPV6=m and NETPOLL=y using this symbol will not work.
