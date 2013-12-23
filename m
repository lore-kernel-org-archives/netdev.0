From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: unneccessary to get address prefix in addrconf_get_prefix_route
Date: Mon, 23 Dec 2013 13:37:15 +0100
Message-ID: <20131223123715.GN14073@order.stressinduktion.org>
References: <1387762358-10607-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:47456 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752939Ab3LWMhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 07:37:17 -0500
Content-Disposition: inline
In-Reply-To: <1387762358-10607-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 23, 2013 at 09:32:38AM +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> Since addrconf_get_prefix_route inputs the address prefix to fib6_locate,
> which does not uses the data which is out of the prefix_len length,
> so do not need to use ipv6_addr_prefix to get address prefix.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

It was necessary before (a long time ago) but when switching to fib_locate* it
became unnecessary.

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
 
