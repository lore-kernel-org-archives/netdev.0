From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethernet: fix checkpatch errors
Date: Tue, 17 Apr 2012 22:50:18 -0400 (EDT)
Message-ID: <20120417.225018.2141913804796063004.davem@davemloft.net>
References: <1334672844-10129-1-git-send-email-laura@rosedu.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, nhorman@tuxdriver.com
To: laura@rosedu.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33013 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751623Ab2DRCv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 22:51:28 -0400
In-Reply-To: <1334672844-10129-1-git-send-email-laura@rosedu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Laura Vasilescu <laura@rosedu.org>
Date: Tue, 17 Apr 2012 17:27:24 +0300

> Signed-off-by: Laura Vasilescu <laura@rosedu.org>

I'd rather have the checkpath errors than what we end up with
your changes:

> -	else if (1 /*dev->flags&IFF_PROMISC */ ) {
> -		if (unlikely(compare_ether_addr_64bits(eth->h_dest, dev->dev_addr)))
> +	else if (1 /*dev->flags&IFF_PROMISC */) {
> +		if (unlikely(compare_ether_addr_64bits(eth->h_dest,
> +							dev->dev_addr)))

This indentation is wrong, the "dev->dev_addr" argument must line up
with the first column after the openning parenthesis on the previous
line.

> -int eth_header_cache(const struct neighbour *neigh, struct hh_cache *hh, __be16 type)
> +int eth_header_cache(const struct neighbour *neigh,
> +			struct hh_cache *hh,
> +			__be16 type)

Same problem here for hh and type args.
