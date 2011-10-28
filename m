From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix route error binding peer in func
 icmp6_dst_alloc
Date: Fri, 28 Oct 2011 16:36:33 -0400 (EDT)
Message-ID: <20111028.163633.356080215479479922.davem@davemloft.net>
References: <1319806017-6131-1-git-send-email-omarapazanadi@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	gaofeng@cn.fujitsu.com
To: omarapazanadi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33132 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751128Ab1J1Ugn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2011 16:36:43 -0400
In-Reply-To: <1319806017-6131-1-git-send-email-omarapazanadi@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <omarapazanadi@gmail.com>
Date: Fri, 28 Oct 2011 20:46:57 +0800

> in func icmp6_dst_alloc,dst_metric_set call ipv6_cow_metrics to set metric.
> ipv6_cow_metrics may will call rt6_bind_peer to set rt6_info->rt6i_peer.
> So,we should move ipv6_addr_copy before dst_metric_set to make sure rt6_bind_peer success.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>

Applied, thanks.
