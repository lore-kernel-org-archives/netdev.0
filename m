From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mvneta: Fix memory use after free.
Date: Mon, 09 Nov 2015 21:48:41 -0500 (EST)
Message-ID: <20151109.214841.1605479864705880795.davem@davemloft.net>
References: <1447118465-9860-1-git-send-email-jmaggard@netgear.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jmaggard@netgear.com
To: jmaggard10@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47425 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751275AbbKJCsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2015 21:48:50 -0500
In-Reply-To: <1447118465-9860-1-git-send-email-jmaggard@netgear.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Justin Maggard <jmaggard10@gmail.com>
Date: Mon,  9 Nov 2015 17:21:05 -0800

> After changing an interface's MTU, then bringing the interface down and
> back up again, I immediately saw tons of kernel messages like below.
> The reason for this bad behavior is mvneta_rxq_drop_pkts(), which calls
> dma_unmap_single() on already-freed memory.  So we need to switch the
> order of those two operations.
 ...
> Signed-off-by: Justin Maggard <jmaggard@netgear.com>

Applied, thanks Justin.
