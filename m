From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: use TOS marks from sockets for routing
 decision
Date: Sat, 11 Jun 2016 15:33:36 -0700 (PDT)
Message-ID: <20160611.153336.594922732979955241.davem@davemloft.net>
References: <1465668499-11740-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, liam.mcbirnie@boeing.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40411 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752996AbcFKWdk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2016 18:33:40 -0400
In-Reply-To: <1465668499-11740-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sat, 11 Jun 2016 20:08:19 +0200

> In IPv6 the ToS values are part of the flowlabel in flowi6 and get
> extracted during fib rule lookup, but we forgot to correctly initialize
> the flowlabel before the routing lookup.
> 
> Reported-by: <liam.mcbirnie@boeing.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
