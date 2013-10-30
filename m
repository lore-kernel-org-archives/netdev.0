From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ibm emac: Fix locking for enable/disable eob irq
Date: Tue, 29 Oct 2013 22:58:27 -0400 (EDT)
Message-ID: <20131029.225827.1459363885174411483.davem@davemloft.net>
References: <1383090638-21526-1-git-send-email-alistair@popple.id.au>
	<1383090638-21526-2-git-send-email-alistair@popple.id.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benh@kernel.crashing.org
To: alistair@popple.id.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52388 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752527Ab3J3C62 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 22:58:28 -0400
In-Reply-To: <1383090638-21526-2-git-send-email-alistair@popple.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alistair Popple <alistair@popple.id.au>
Date: Wed, 30 Oct 2013 10:50:38 +1100

> Calls to mal_enable_eob_irq perform a read-write-modify of a dcr to
> enable device irqs which is protected by a spin lock. However calls to
> mal_disable_eob_irq do not take the corresponding lock.
> 
> This patch resolves the problem by ensuring that calls to
> mal_disable_eob_irq also take the lock.
> 
> Signed-off-by: Alistair Popple <alistair@popple.id.au>

Applied.
