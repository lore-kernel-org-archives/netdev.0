From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 3/9] net: Add fast receive encapsulation
Date: Fri, 25 Mar 2016 16:40:42 -0400 (EDT)
Message-ID: <20160325.164042.1532577255302949895.davem@davemloft.net>
References: <1458772618-845742-1-git-send-email-tom@herbertland.com>
	<1458772618-845742-4-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45810 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753033AbcCYUkr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 16:40:47 -0400
In-Reply-To: <1458772618-845742-4-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Wed, 23 Mar 2016 15:36:52 -0700

> +{
> +	struct udp_sock *up = udp_sk(sk);
> +	int is_udplite = IS_UDPLITE(sk);
> +
> +	int (*encap_rcv)(struct sock *sk, struct sk_buff *skb);
> +

Small nit, please put this encap_rcv function pointer declaration at
the top of the local variable list.
