From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: update Destination Cache entries when gateway
 turn into host
Date: Mon, 12 May 2014 01:01:52 -0400 (EDT)
Message-ID: <20140512.010152.808234287210437125.davem@davemloft.net>
References: <536C4A74.2050103@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org
To: duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54950 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751120AbaELFBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 01:01:54 -0400
In-Reply-To: <536C4A74.2050103@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Date: Fri, 9 May 2014 11:24:36 +0800

> +/*remove routers and update dst entries when gateway turn into host.*/

This comment is poorly formatted.

Please put a space after "/*", capitalize "Remove" and place
a space before "*/" at the end of the comment.

> +static int fib6_clean_tohost(struct rt6_info *rt, void *arg)
> +{
> +	struct in6_addr *gateway = (struct in6_addr *)arg;
> +
> +	if (((rt->rt6i_flags & (RTF_ADDRCONF | RTF_DEFAULT | RTF_GATEWAY))
> +	    == (RTF_ADDRCONF | RTF_DEFAULT | RTF_GATEWAY))
> +	    && ipv6_addr_equal(gateway, &rt->rt6i_gateway)) {

This conditional is poorly formatted:

> +	} else if (((rt->rt6i_flags & (RTF_GATEWAY | RTF_CACHE))
> +		      == (RTF_GATEWAY | RTF_CACHE))
> +		    && ipv6_addr_equal(gateway, &rt->rt6i_gateway)) {

As is this one.

Never put operators at the beginning of a continuation line, rather
put them at the end of the previous line.  This includes "&&", "||",
and "=="
