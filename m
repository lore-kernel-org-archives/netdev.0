From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6] net: introduce rcu_dereference_rtnl
Date: Wed, 08 Sep 2010 19:29:27 +0100
Message-ID: <1283970567.2237.0.camel@achroite.uk.solarflarecom.com>
References: <1283890291.2634.143.camel@edumazet-laptop>
	 <4C86A558.6030802@gmail.com>  <1283893657.2634.210.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:30411 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753000Ab0IHS3b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 14:29:31 -0400
In-Reply-To: <1283893657.2634.210.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-09-07 at 23:07 +0200, Eric Dumazet wrote:
[...]
> +/**
> + * rcu_dereference_rtnl - rcu_dereference with debug checking
> + * @p: The pointer to read, prior to dereferencing
> + *
> + * Do an rcu_dereference(p), but check caller either holds rcu_read_lock()
> + * or RTNL
> + */
> +#define rcu_dereference_rtnl(p)					\
> +	rcu_dereference_check(p, rcu_read_lock_held() ||	\
> +				 lockdep_rtnl_is_held());
[...]

No semicolon on the end, please.  The 'caller' will add that.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


