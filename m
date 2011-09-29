From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net/stable] can bcm: fix tx_setup off-by-one errors
Date: Thu, 29 Sep 2011 00:33:17 -0400 (EDT)
Message-ID: <20110929.003317.223715542181691202.davem@davemloft.net>
References: <4E7CCEB3.4050408@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org, nautsch@gmail.com
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37289 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753228Ab1I2EhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2011 00:37:21 -0400
In-Reply-To: <4E7CCEB3.4050408@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Fri, 23 Sep 2011 20:23:47 +0200

> This patch fixes two off-by-one errors that canceled each other out.
> Checking for the same condition two times in bcm_tx_timeout_tsklet() reduced
> the count of frames to be sent by one. This did not show up the first time
> tx_setup is invoked as an additional frame is sent due to TX_ANNONCE.
> Invoking a second tx_setup on the same item led to a reduced (by 1) number of
> sent frames.
> 
> Reported-by: Andre Naujoks <nautsch@gmail.com>
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

Applied, and queued up for -stable.
