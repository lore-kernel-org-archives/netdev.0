From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 2/7] tou: Base infrastructure for Transport over UDP
Date: Tue, 24 May 2016 15:02:05 -0700 (PDT)
Message-ID: <20160524.150205.348154689936562323.davem@davemloft.net>
References: <1464043706-2843932-1-git-send-email-tom@herbertland.com>
	<1464043706-2843932-3-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60197 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754076AbcEXWCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2016 18:02:06 -0400
In-Reply-To: <1464043706-2843932-3-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Mon, 23 May 2016 15:48:21 -0700

> +int tou_encap_setsockopt(struct sock *sk, char __user *optval, int optlen,
> +			 bool is_ipv6)
> +{
> +	struct tou_encap te;
> +	struct ip_tunnel_encap encap;
> +	struct inet_sock *inet = inet_sk(sk);
> +	struct ip_tunnel_encap *e = inet->tou_encap;

This doesn't compile, because you don't add the tou_encap member to inet_sock
until patch #3.
