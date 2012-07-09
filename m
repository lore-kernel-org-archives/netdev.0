From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] cnic: Don't use netdev->base_addr
Date: Mon, 09 Jul 2012 00:18:35 -0700 (PDT)
Message-ID: <20120709.001835.1664117705002732138.davem@davemloft.net>
References: <1341534115-710-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53646 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752514Ab2GIHSf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 03:18:35 -0400
In-Reply-To: <1341534115-710-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 5 Jul 2012 17:21:55 -0700

>     commit c0357e975afdbbedab5c662d19bef865f02adc17
>     bnx2: stop using net_device.{base_addr, irq}.
> 
> removed netdev->base_addr so we need to update cnic to get the MMIO
> base address from pci_resource_start().  Otherwise, mmap of the uio
> device will fail.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
