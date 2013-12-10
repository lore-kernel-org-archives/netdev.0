From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] neigh: use neigh_parms_net() to get struct
 neigh_parms->net pointer
Date: Tue, 10 Dec 2013 17:59:29 -0500 (EST)
Message-ID: <20131210.175929.828518960842627263.davem@davemloft.net>
References: <1386716107-18843-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52882 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750921Ab3LJW7a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 17:59:30 -0500
In-Reply-To: <1386716107-18843-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 10 Dec 2013 23:55:07 +0100

> This fixes compile error when CONFIG_NET_NS is not set.
> 
> Introduced by:
> commit 1d4c8c29841b9991cdf3c7cc4ba7f96a94f104ca
>     "neigh: restore old behaviour of default parms values"
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
 ...
> -	struct net *net = p->net;
> +	struct net *net = neigh_parms_net(p);

Hey look at that, the interface already existed :-)

Applied, thanks Jiri.
