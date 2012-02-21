From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] mlx4_core: Do not map BF area if capability is 0
Date: Mon, 20 Feb 2012 19:26:54 -0500 (EST)
Message-ID: <20120220.192654.417785054157102848.davem@davemloft.net>
References: <4F41F88C.3070607@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jackm@dev.mellanox.co.il
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50958 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754814Ab2BUA1E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2012 19:27:04 -0500
In-Reply-To: <4F41F88C.3070607@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Mon, 20 Feb 2012 09:38:52 +0200

> From: Jack Morgenstein <jackm@dev.mellanox.co.il>
> 
> BF can be disabled in some cases, the capability field, bf_reg_size is set
> to zero in this case. Don't map the BF area in this case, it would cause 
> failures.  In addition, leaving the BF area unmapped
> also alerts the ETH driver to not use BF.
> 
> Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>

Applied, thanks.
