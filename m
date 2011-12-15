From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH] phylib: update mdiobus_alloc() to allocate extra private space
Date: Thu, 15 Dec 2011 12:06:01 -0500
Message-ID: <8ABCAC4C-1D11-41AD-AE46-96EB9D40588D@freescale.com>
References: <1323967895-5205-1-git-send-email-timur@freescale.com>
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linuxppc-dev@ozlabs.org>
To: Timur Tabi <timur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe003.messaging.microsoft.com ([65.55.88.13]:47644 "EHLO
	TX2EHSOBE006.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759098Ab1LOROz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2011 12:14:55 -0500
In-Reply-To: <1323967895-5205-1-git-send-email-timur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Dec 15, 2011, at 11:51 AM, Timur Tabi wrote:

> Augment mdiobus_alloc() to take a parameter indicating the number of extra
> bytes to allocate for private data.  Almost all callers of mdiobus_alloc()
> separately allocate a private data structure.  By allowing mdiobus_alloc()
> to allocate extra memory, the two allocations can be merged into one.
> 
> This patch does not change any of the callers to actually take advantage
> of this feature, however.  That change can be made by the individual
> maintainers at their leisure.  For now, all callers ask for zero additional
> bytes, which mimics the previous behavior.


Why? Doesn't this just obfuscate things a little, while providing no immediate benefit?

Andy
