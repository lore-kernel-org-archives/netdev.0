From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] fou: clean up socket with kfree_rcu
Date: Wed, 16 Dec 2015 19:03:36 -0500 (EST)
Message-ID: <20151216.190336.1728452196062056833.davem@davemloft.net>
References: <1450209714-26037-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41850 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750792AbbLQADk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 19:03:40 -0500
In-Reply-To: <1450209714-26037-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 15 Dec 2015 21:01:53 +0100

> fou->udp_offloads is managed by RCU. As it is actually included inside
> the fou sockets, we cannot let the memory go out of scope before a grace
> period. We either can synchronize_rcu or switch over to kfree_rcu to
> manage the sockets. kfree_rcu seems appropriate as it is used by vxlan
> and geneve.
> 
> Fixes: 23461551c00628c ("fou: Support for foo-over-udp RX path")
> Cc: Tom Herbert <tom@herbertland.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
