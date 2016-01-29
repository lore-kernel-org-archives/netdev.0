From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: beware of alignments in tcp_get_info()
Date: Thu, 28 Jan 2016 22:50:26 -0800 (PST)
Message-ID: <20160128.225026.2097479414986216382.davem@davemloft.net>
References: <1453920763.20722.23.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34235 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752446AbcA2Gua (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 01:50:30 -0500
In-Reply-To: <1453920763.20722.23.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 27 Jan 2016 10:52:43 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> With some combinations of user provided flags in netlink command,
> it is possible to call tcp_get_info() with a buffer that is not 8-bytes
> aligned.
> 
> It does matter on some arches, so we need to use put_unaligned() to
> store the u64 fields.
> 
> Current iproute2 package does not trigger this particular issue.
> 
> Fixes: 0df48c26d841 ("tcp: add tcpi_bytes_acked to tcp_info")
> Fixes: 977cb0ecf82e ("tcp: add pacing_rate information into tcp_info")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks Eric.
