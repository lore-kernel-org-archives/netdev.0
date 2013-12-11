From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next] 8390 : Replace ei_debug with
 msg_enable/NETIF_MSG_* feature
Date: Wed, 11 Dec 2013 17:12:24 -0500 (EST)
Message-ID: <20131211.171224.2111686395095015308.davem@davemloft.net>
References: <1386799259-31623-1-git-send-email-tedheadster@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tedheadster@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60104 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751941Ab3LKWM1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 17:12:27 -0500
In-Reply-To: <1386799259-31623-1-git-send-email-tedheadster@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Whitehead <tedheadster@gmail.com>
Date: Wed, 11 Dec 2013 17:00:59 -0500

> Removed the shared ei_debug variable. Replaced it by adding u32 msg_enable to
> the private struct ei_device. Now each 8390 ethernet instance has a per-device
> logging variable.
> 
> Changed older style printk() calls to more canonical forms.
> 
> Tested on: ne, ne2k-pci, smc-ultra, and wd hardware.
> 
> V4.0
> - Substituted pr_info() and pr_debug() for printk() KERN_INFO and KERN_DEBUG
> 
> V3.0
> - Checked for cases where pr_cont() was most appropriate choice.
> - Changed module parameter from 'debug' to 'msg_enable' because debug was
> no longer the best description.
> 
> V2.0
> - Changed netif_msg_(drv|probe|ifdown|rx_err|tx_err|tx_queued|intr|rx_status|hw)
> to netif_(dbg|info|warn|err) where possible.
> 
> Signed-off-by: Matthew Whitehead <tedheadster@gmail.com>

Applied, but there was some trailing whitespace I had to edit out while
applying this, thanks.
