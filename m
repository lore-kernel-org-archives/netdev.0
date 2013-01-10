From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ethernet: xilinx: Do not use NO_IRQ in axienet
Date: Thu, 10 Jan 2013 14:38:08 -0800 (PST)
Message-ID: <20130110.143808.1759152434749002223.davem@davemloft.net>
References: <1357837123-18996-1-git-send-email-michal.simek@xilinx.com>
	<1357837123-18996-2-git-send-email-michal.simek@xilinx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: michal.simek@xilinx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34552 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753276Ab3AJWiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 17:38:08 -0500
In-Reply-To: <1357837123-18996-2-git-send-email-michal.simek@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Simek <michal.simek@xilinx.com>
Date: Thu, 10 Jan 2013 17:58:43 +0100

> This driver is used on Microblaze and will be used
> on Arm Zynq.
> Microblaze doesn't define NO_IRQ and no IRQ is 0.
> Arm still uses NO_IRQ as -1 and there is no option
> to connect IRQ to irq 0.
> 
> That's why <= 0 is only one option how to find out
> undefined IRQ.
> 
> Signed-off-by: Michal Simek <michal.simek@xilinx.com>

Applied.
