From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ipv6: move IPV6_TCLASS_SHIFT into ipv6.h
Date: Mon, 13 Jan 2014 21:25:40 -0800 (PST)
Message-ID: <20140113.212540.653813046935024687.davem@davemloft.net>
References: <1389348199-5855-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40855 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751678AbaANFZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 00:25:41 -0500
In-Reply-To: <1389348199-5855-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Fri, 10 Jan 2014 18:03:18 +0800

> @@ -150,6 +150,8 @@ static int fib6_rule_match(struct fib_rule *rule, struct flowi *fl, int flags)
>  {
>  	struct fib6_rule *r = (struct fib6_rule *) rule;
>  	struct flowi6 *fl6 = &fl->u.ip6;
> +	u8 tclass = ntohl(fl6->flowlabel & IPV6_TCLASS_MASK) >>
> +		    IPV6_TCLASS_SHIFT;

As others have mentioned, please make a helper inline function or
macro for this calculation.  It happens in two places.


Thanks.
