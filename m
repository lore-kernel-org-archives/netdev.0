From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] b44: remove __exit from b44_pci_exit()
Date: Sun, 19 Feb 2012 18:58:11 -0500 (EST)
Message-ID: <20120219.185811.1602965172431248468.davem@davemloft.net>
References: <74eccdc061524ad9ab6aae1ca0dd7a020921b1fe.1329684207.git.n.pajkovsky@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zambrano@broadcom.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: n.pajkovsky@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40612 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751194Ab2BSX6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2012 18:58:23 -0500
In-Reply-To: <74eccdc061524ad9ab6aae1ca0dd7a020921b1fe.1329684207.git.n.pajkovsky@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikola Pajkovsky <n.pajkovsky@gmail.com>
Date: Sun, 19 Feb 2012 21:47:43 +0100

> WARNING: drivers/net/ethernet/broadcom/built-in.o(.init.text+0x5d): Section mismatch in reference from the function b44_init() to the function .exit.text:b44_pci_exit()
> 
> module exits with b44_cleanup()
> 
> Signed-off-by: Nikola Pajkovsky <n.pajkovsky@gmail.com>

Applied.
