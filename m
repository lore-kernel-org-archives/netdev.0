From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] ne2k-pci: Add pci_disable_device in error handling
Date: Thu, 25 Dec 2014 18:30:06 -0500 (EST)
Message-ID: <20141225.183006.2284933142786925265.davem@davemloft.net>
References: <1419305343-29032-1-git-send-email-baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhelgaas@google.com, benoit.taine@lip6.fr, netdev@vger.kernel.org
To: baijiaju1990@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58650 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751669AbaLYXaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Dec 2014 18:30:08 -0500
In-Reply-To: <1419305343-29032-1-git-send-email-baijiaju1990@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jia-Ju Bai <baijiaju1990@163.com>
Date: Tue, 23 Dec 2014 11:29:03 +0800

> For linux-3.18.0
> The driver lacks pci_disable_device in error handling code of
> ne2k_pci_init_one, so the device enabled by pci_enable_device is not
> disabled when errors occur.
> This patch fixes this problem.
> 
> Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>

Applied, thanks.
