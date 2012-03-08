From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] mlx4_core: fix bug in modify_cq wrapper for resize
 flow.
Date: Thu, 08 Mar 2012 00:28:57 -0800 (PST)
Message-ID: <20120308.002857.343249677648165570.davem@davemloft.net>
References: <4F578533.3090405@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jackm@dev.mellanox.co.il
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58937 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755162Ab2CHI3F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2012 03:29:05 -0500
In-Reply-To: <4F578533.3090405@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Wed, 7 Mar 2012 17:56:35 +0200

> From: Jack Morgenstein <jackm@dev.mellanox.co.il>
> 
> The actual FW command is called in procedure "handle_resize".
> Code incorrectly invoked the FW command again (in good flow), in
> the modify_cq wrapper function.
> 
> Fix by skipping second FW invocation unconditionally for resize.
> 
> Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>

Applied.
