From: David Miller <davem@davemloft.net>
Subject: Re: bridge/netfilter: regression in 2.6.39.1
Date: Tue, 07 Jun 2011 00:52:18 -0700 (PDT)
Message-ID: <20110607.005218.1185277553215106816.davem@davemloft.net>
References: <1307366166.3098.15.camel@edumazet-laptop>
	<4DECD657.9010807@ahsoftware.de>
	<1307370363.3098.37.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: holler@ahsoftware.de, nhorman@tuxdriver.com,
	linux-kernel@vger.kernel.org, herbert@gondor.hengli.com.au,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42554 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751135Ab1FGHxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2011 03:53:38 -0400
In-Reply-To: <1307370363.3098.37.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 06 Jun 2011 16:26:03 +0200

> [PATCH] bridge: provide a cow_metrics method for fake_ops
> 
> Like in commit 0972ddb237 (provide cow_metrics() methods to blackhole
> dst_ops), we must provide a cow_metrics for bridges fake_dst_ops as
> well.
> 
> This fixes a regression coming from commits 62fa8a846d7d (net: Implement
> read-only protection and COW'ing of metrics.) and 33eb9873a28 (bridge:
> initialize fake_rtable metrics)
> 
> ip link set mybridge mtu 1234
> -->
 ...
> Signed-off-by: Alexander Holler <holler@ahsoftware.de>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>


Applied, thanks everyone.
