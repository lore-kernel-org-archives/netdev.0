From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/4] Replace wmb()/rmb() with
 dma_wmb()/dma_rmb() where appropriate, round 2
Date: Thu, 09 Apr 2015 14:32:47 -0400 (EDT)
Message-ID: <20150409.143247.7034121003688003.davem@davemloft.net>
References: <20150409014001.4434.85280.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49702 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932851AbbDISct (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 14:32:49 -0400
In-Reply-To: <20150409014001.4434.85280.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Wed, 08 Apr 2015 18:49:23 -0700

> More cleanup of drivers in order to start making use of dma_rmb and dma_wmb
> calls.  This is another pass of what I would consider to be low hanging
> fruit.  There may be other opportunities to make use of the barriers in the
> Mellanox and Chelsio drivers but I didn't want to risk meddling with code I
> was not completely familiar with so I am leaving that for future work.
> 
> I have revisited the Mellanox driver changes.  This time around I went only
> for the sections with a clearly defined pattern.  For dma_wmb I used it
> between accesses of the descriptor bits followed by owner or size.  For
> dma_wmb I used it to replace rmb following a read of the ownership bit in
> the descriptor.

Series applied with fixed commit message.
