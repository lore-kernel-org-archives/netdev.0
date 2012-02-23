From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] mlx4_en: moderate frequency of TX
 completions
Date: Thu, 23 Feb 2012 16:47:56 -0500 (EST)
Message-ID: <20120223.164756.887751433359593643.davem@davemloft.net>
References: <20120223.144437.32389814881687535.davem@davemloft.net>
	<1330031636.2511.13.camel@bwh-desktop>
	<1330032380.2511.17.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yevgenyp@mellanox.co.il, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56695 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752535Ab2BWVsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 16:48:03 -0500
In-Reply-To: <1330032380.2511.17.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 23 Feb 2012 21:26:20 +0000

> And it's pretty obvious the hardware has to also send a completion when
> the queue is empty.  I hope.

Right and we know of several chips that don't.
