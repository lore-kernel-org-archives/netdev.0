From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net/stable] can bcm: fix tx_setup off-by-one errors
Date: Thu, 29 Sep 2011 03:58:09 -0400 (EDT)
Message-ID: <20110929.035809.1014076114218537552.davem@davemloft.net>
References: <4E7CCEB3.4050408@hartkopp.net>
	<20110929.003317.223715542181691202.davem@davemloft.net>
	<4E842266.9090407@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org, nautsch@gmail.com
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57659 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754625Ab1I2ICP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2011 04:02:15 -0400
In-Reply-To: <4E842266.9090407@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Thu, 29 Sep 2011 09:46:46 +0200

> when backporting the patch to an older kernel we discovered a problem this
> patch is introducing - which causes a new regression :-(
> 
> Could you please revert this patch and dequeue it from stable?

It's already pushed out to the net GIT tree, I can't delete history so
now the only thing I can do is add a butt-ugly revert commit this late
in the -rcX which is terrible.

This patch was sitting out there for review for 6 days, which should
have been more than enough time to audit it for problems.
