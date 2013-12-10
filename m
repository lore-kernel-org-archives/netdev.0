From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 0/5] neigh: respect default parms values
Date: Mon, 09 Dec 2013 20:56:57 -0500 (EST)
Message-ID: <20131209.205657.22934541767894302.davem@davemloft.net>
References: <1386440817-7846-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	hannes@stressinduktion.org, bcrl@kvack.org, gaofeng@cn.fujitsu.com,
	joe@perches.com, herbert@gondor.apana.org.au
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44989 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750805Ab3LJB5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 20:57:00 -0500
In-Reply-To: <1386440817-7846-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Sat,  7 Dec 2013 19:26:52 +0100

> This is a long standing regression. But since the patchset is bigger and
> the regression happened in 2007, I'm proposing this to net-next instead.
> 
> Basically the problem is that if user wants to use /etc/sysctl.conf to specify
> default values of neigh related params, he is not able to do that.
> 
> The reason is that the default values are copied to dev instance right after
> netdev is registered. And that is way to early. The original behaviour
> for ipv4 was that this happened after first address was assigned to device.
> For ipv6 this was apparently from the very beginning.
> 
> So this patchset basically reverts the behaviour back to what it was in 2007 for
> ipv4 and changes the behaviour for ipv6 so they are both the same.
> 
> v1->v2:
> - use neigh_parms->tbl->family as suggested by davem

Series applied, thanks Jiri.
