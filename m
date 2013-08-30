From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv6:introduce function to find route for redirect
Date: Fri, 30 Aug 2013 14:50:40 -0400 (EDT)
Message-ID: <20130830.145040.1365637205836405921.davem@davemloft.net>
References: <52204876.3090803@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55903 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752855Ab3H3Sum (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 14:50:42 -0400
In-Reply-To: <52204876.3090803@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Date: Fri, 30 Aug 2013 15:23:34 +0800

> +	/*
> +	 * Get the "current" route for this destination and
> +	 * check if the redirect has come from approriate router.
> +	 *
> +	 * RFC 4861 specifies that redirects should only be
> +	 * accepted if they come from the nexthop to the target.
> +	 * Due to the way the routes are chosen, this notion
> +	 * is a bit fuzzy and one might need to check all possible
> +	 * routes.
> +	 */

Comments in the networking code should be formatted:

	/* Like
	 * this.
	 */
