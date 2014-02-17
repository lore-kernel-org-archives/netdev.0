From: David Miller <davem@davemloft.net>
Subject: Re: drivers/net: tulip_remove_one needs to call
 pci_disable_device()
Date: Mon, 17 Feb 2014 00:19:44 -0500 (EST)
Message-ID: <20140217.001944.2069275324958551151.davem@davemloft.net>
References: <1392388340-6527-1-git-send-email-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grundler@parisc-linux.org, netdev@vger.kernel.org, mingo@elte.hu,
	tglx@linutronix.de
To: bigeasy@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40108 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751005AbaBQFTp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 00:19:45 -0500
In-Reply-To: <1392388340-6527-1-git-send-email-bigeasy@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Fri, 14 Feb 2014 15:32:20 +0100

> From: Ingo Molnar <mingo@elte.hu>
> 
> Otherwise the device is not completely shut down.
> 
> Signed-off-by: Ingo Molnar <mingo@elte.hu>
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

Looks good, applied, thanks.
