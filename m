From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv6: Introduce ip6_sk_dst_hoplimit.
Date: Mon, 28 Apr 2014 14:46:25 -0400 (EDT)
Message-ID: <20140428.144625.195499058887458867.davem@davemloft.net>
References: <1398666518-7715-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45014 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756495AbaD1TXO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 15:23:14 -0400
In-Reply-To: <1398666518-7715-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Mon, 28 Apr 2014 15:28:38 +0900

> +static inline int ip6_sk_dst_hoplimit(struct ipv6_pinfo *np, struct flowi6 *fl6,
> +				      struct dst_entry *dst)
> +{
> +	int hlimit;
> +	if (ipv6_addr_is_multicast(&fl6->daddr))
> +		hlimit = np->mcast_hops;

Please place an empty line between local variable declarations and actual
code.
