From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] dummy: Add ndo_uninit().
Date: Mon, 16 Apr 2012 23:57:00 -0400 (EDT)
Message-ID: <20120416.235700.92011132488911415.davem@davemloft.net>
References: <20120416082601.ac00a86d.shimoda.hiroaki@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shimoda.hiroaki@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50740 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755478Ab2DQD5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2012 23:57:03 -0400
In-Reply-To: <20120416082601.ac00a86d.shimoda.hiroaki@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Date: Mon, 16 Apr 2012 08:26:01 +0900

> In register_netdevice(), when ndo_init() is successful and later
> some error occurred, ndo_uninit() will be called.
> So dummy deivce is desirable to implement ndo_uninit() method
> to free percpu stats for this case.
> And, ndo_uninit() is also called along with dev->destructor() when
> device is unregistered, so in order to prevent dev->dstats from
> being freed twice, dev->destructor is modified to free_netdev().
> 
> Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>

Applied and queued up for -stable, thanks.
