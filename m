From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [net-next PATCH 2/3] net: fix enforcing of fragment queue hash list depth
Date: Fri, 19 Apr 2013 02:52:17 +0200
Message-ID: <20130419005217.GD27889@order.stressinduktion.org>
References: <20130418213637.14296.43143.stgit@dragon> <20130418213732.14296.36026.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:51431 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967655Ab3DSAwS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 20:52:18 -0400
Content-Disposition: inline
In-Reply-To: <20130418213732.14296.36026.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 18, 2013 at 11:38:00PM +0200, Jesper Dangaard Brouer wrote:
> -	if (PTR_ERR(q) == -ENOBUFS)
> -		LIMIT_NETDEBUG(KERN_WARNING "%s%s", prefix, msg);
> +		LIMIT_NETDEBUG(KERN_WARNING "%s(): Fragment hash bucket"
> +			       " list length grew over limit (len %d),"
> +			       " Dropping another fragment.\n",
> +			       __func__, depth);
> +	}

Simple nice-to-have thingie: Do you see a simple possibility to add the
user (e.g.  ipv6/ipv6-netfilter/ipv4) to the warning?
