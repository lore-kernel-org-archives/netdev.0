From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCHv2] ipv6: Fix inet6_init() cleanup order
Date: Sat, 16 Nov 2013 21:26:46 +0100
Message-ID: <20131116202646.GE16541@order.stressinduktion.org>
References: <1384633044-26453-1-git-send-email-vyasevich@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, Lorenzo Colitti <lorenzo@google.com>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:47397 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752584Ab3KPU0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Nov 2013 15:26:48 -0500
Content-Disposition: inline
In-Reply-To: <1384633044-26453-1-git-send-email-vyasevich@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 16, 2013 at 03:17:24PM -0500, Vlad Yasevich wrote:
> Commit 6d0bfe22611602f36617bc7aa2ffa1bbb2f54c67
> 	net: ipv6: Add IPv6 support to the ping socket
> 
> introduced a change in the cleanup logic of inet6_init and
> has a bug in that ipv6_packet_cleanup() may not be called.
> Fix the cleanup ordering.
> 
> CC: Hannes Frederic Sowa <hannes@stressinduktion.org>
> CC: Lorenzo Colitti <lorenzo@google.com>
> CC: Fabio Estevam <fabio.estevam@freescale.com>
> Signed-off-by: Vlad Yasevich <vyasevich@gmail.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,

  Hannes
