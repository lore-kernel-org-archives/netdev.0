From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mlx4_en: Change BQL reset TX queue call point
Date: Sun, 03 Feb 2013 16:13:29 -0500 (EST)
Message-ID: <20130203.161329.867394389053130890.davem@davemloft.net>
References: <alpine.DEB.2.00.1302011659200.14247@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yevgenyp@mellanox.com, netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34520 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753600Ab3BCVNb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Feb 2013 16:13:31 -0500
In-Reply-To: <alpine.DEB.2.00.1302011659200.14247@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Fri, 1 Feb 2013 17:02:50 -0800 (PST)

> Fix issue in Mellanox driver related to BQL.  netdev_tx_reset_queue
> was not being called in certain situations where the device was
> being start and stopped.  Moved netdev_tx_reset_queue from the reset
> device path to mlx4_en_free_tx_buf which is where the rings are
> cleaned in a reset (specifically from device being stopped).
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

This doesn't apply to net-next, please respin.
