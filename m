From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] mlx4_core: fix mtt range deallocation
Date: Tue, 03 Jan 2012 13:01:08 -0500 (EST)
Message-ID: <20120103.130108.238896737013725266.davem@davemloft.net>
References: <4F01BA2B.1060605@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, marcela@dev.mellanox.co.il
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41011 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754283Ab2ACSBT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 13:01:19 -0500
In-Reply-To: <4F01BA2B.1060605@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Mon, 2 Jan 2012 16:07:39 +0200

> From: Marcel Apfelbaum <marcela@mellanox.co.il>
> 
> The mtt range was allocated in mtt units but deallocated
> in segments. Among the rest, this caused crash during hotplug removal
> 
> Reported-by: Yinghai Lu <yinghai@kernel.org> 
> Signed-off-by: Marcel Apfelbaum <marcela@mellanox.co.il>
> Reviewed-by: Jack Morgenstein <jackm@dev.mellanox.co.il>

Applied.
