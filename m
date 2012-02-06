From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 3/3] mlx4_core: use correct port for steering
Date: Mon, 06 Feb 2012 12:13:29 -0500 (EST)
Message-ID: <20120206.121329.87082605134931722.davem@davemloft.net>
References: <4F2FFF3C.6050308@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eugenia@mellanox.co.il
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51223 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755654Ab2BFRNg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 12:13:36 -0500
In-Reply-To: <4F2FFF3C.6050308@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Mon, 6 Feb 2012 18:26:36 +0200

> From: Eugenia Emantayev <eugenia@mellanox.co.il>
> 
> Use port number for correct steering (list per port).
> Before the fix all steering entries (for both physical ports)
> were managed in first port structures, so we had leakage of resources
> for port 2.
> 
> Signed-off-by: Eugenia Emantayev <eugenia@mellanox.co.il>

Applied.
