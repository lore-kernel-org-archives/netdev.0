From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2 1/1] drivers: net: cpsw: fix kernel warn on
 cpsw irq enable
Date: Tue, 30 Apr 2013 15:48:18 -0400 (EDT)
Message-ID: <20130430.154818.1553726715413608388.davem@davemloft.net>
References: <1367314048-11503-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org,
	bigeasy@linutronix.de
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52667 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932708Ab3D3TsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 15:48:20 -0400
In-Reply-To: <1367314048-11503-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Tue, 30 Apr 2013 14:57:28 +0530

> With the commit a11fbba (net/cpsw: fix irq_disable() with threaded interrupts)
> from Sebastian Siewior, a kernel warning is generated as below. This warning
> is generated as the irq_enabled is not initialized for the primary interface
> and in probe it is initialized for the second interface. This patch moves
> irq_enabled initialization from second interface to primary interface.
 ...
> Cc: Sebastian Siewior <bigeasy@linutronix.de>
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>

Applied, thanks.
