From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH can-next] can: dump stack on protocol bugs
Date: Tue, 19 Mar 2013 09:55:58 -0400 (EDT)
Message-ID: <20130319.095558.766533338565579034.davem@davemloft.net>
References: <51475446.9000604@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mkl@pengutronix.de, netdev@vger.kernel.org
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42752 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754645Ab3CSN4B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 09:56:01 -0400
In-Reply-To: <51475446.9000604@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Mon, 18 Mar 2013 18:52:06 +0100

> The rework of the kernel hlist implementation "hlist: drop the node parameter
> from iterators" (b67bfe0d42cac56c512dd5da4b1b347a23f4b70a) created some
> fallout in the form of non matching comments and obsolete code.
> 
> Additionally to the cleanup this patch adds a WARN() statement to catch the
> caller of the wrong filter removal request.
> 
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

Applied, thanks.
