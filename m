From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: au1000_eth: add MACDMA to platform resource info.
Date: Fri, 20 May 2011 14:56:04 -0400 (EDT)
Message-ID: <20110520.145604.330897605239664622.davem@davemloft.net>
References: <1305916865-14038-1-git-send-email-manuel.lauss@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, netdev@vger.kernel.org,
	linux-mips@linux-mips.org
To: manuel.lauss@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35552 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935041Ab1ETS4P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2011 14:56:15 -0400
In-Reply-To: <1305916865-14038-1-git-send-email-manuel.lauss@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manuel Lauss <manuel.lauss@googlemail.com>
Date: Fri, 20 May 2011 20:41:05 +0200

> This patch removes the last hardcoded base address from the au1000_eth
> driver:  The base of the MACDMA unit was derived from the
> platform device id; if someone registered the MACs in inverse order
> both would not work.
> Instead pass the base address of the DMA unit to the driver along with
> the other platform resource information.
> 
> Signed-off-by: Manuel Lauss <manuel.lauss@googlemail.com>

Acked-by: David S. Miller <davem@davemloft.net>
