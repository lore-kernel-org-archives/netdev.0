From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] mlx4: Setting new port types after all interfaces
 unregistered
Date: Tue, 21 Feb 2012 15:28:44 -0500 (EST)
Message-ID: <20120221.152844.1489964470108810111.davem@davemloft.net>
References: <4F439EF3.8050702@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60343 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752148Ab2BUU24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 15:28:56 -0500
In-Reply-To: <4F439EF3.8050702@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Tue, 21 Feb 2012 15:41:07 +0200

> 
> In port type change flow, need to set the new port types only after
> all interfaces have finished the unregister process.
> Otherwise, during unregister, one of the interfaces might issue a SET_PORT
> command with wrong port types, it can cause bad FW behavior.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Applied.
