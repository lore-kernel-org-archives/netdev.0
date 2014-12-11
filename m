From: David Miller <davem@davemloft.net>
Subject: Re: Bug: mv643xxx fails with highmem
Date: Thu, 11 Dec 2014 15:10:55 -0500 (EST)
Message-ID: <20141211.151055.817876561546126576.davem@davemloft.net>
References: <20141211194920.GR11285@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ezequiel.garcia@free-electrons.com, netdev@vger.kernel.org
To: linux@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56176 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758298AbaLKUK6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 15:10:58 -0500
In-Reply-To: <20141211194920.GR11285@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Date: Thu, 11 Dec 2014 19:49:20 +0000

> Commit 69ad0dd7af22 removed skb_frag_dma_map() in favour of mapping
> all fragments with dma_map_single().  This fails when the driver is
> used in an environment with highmem.

This change looks really buggy to me.

Unfortunately, all the changes he subsequently makes for software TSO
support depend upon this :-/

The change is definitely wrong.
