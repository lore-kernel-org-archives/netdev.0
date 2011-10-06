From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Break up the single NBD lock into one per NBD device
Date: Thu, 06 Oct 2011 15:37:40 -0400 (EDT)
Message-ID: <20111006.153740.1653912067120856697.davem@davemloft.net>
References: <1317080052-6052-1-git-send-email-hkchu@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hkchu@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46855 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759142Ab1JFTho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 15:37:44 -0400
In-Reply-To: <1317080052-6052-1-git-send-email-hkchu@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "H.K. Jerry Chu" <hkchu@google.com>
Date: Mon, 26 Sep 2011 16:34:12 -0700

> From: Jerry Chu <hkchu@google.com>
> 
> This patch breaks up the single NBD lock into one per
> disk. The single NBD lock has become a serious performance
> bottleneck when multiple NBD disks are being used.
> 
> The original comment on why a single lock may be ok no
> longer holds for today's much faster NICs.
> 
> Signed-off-by: H.K. Jerry Chu <hkchu@google.com>

Acked-by: David S. Miller <davem@davemloft.net>

Even though this is a "networking" block device, I think this change
should go through the Jens Axboe's block layer tree.

Thanks.
