From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dm9000: Make the driver follow the IRQF_SHARED contract
Date: Fri, 22 Jul 2011 17:15:34 -0700 (PDT)
Message-ID: <20110722.171534.202703728483982275.davem@davemloft.net>
References: <1311357162-16200-1-git-send-email-daniel.morsing@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: broonie@opensource.wolfsonmicro.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: daniel.morsing@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59197 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755999Ab1GWAPl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2011 20:15:41 -0400
In-Reply-To: <1311357162-16200-1-git-send-email-daniel.morsing@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Morsing <daniel.morsing@gmail.com>
Date: Fri, 22 Jul 2011 19:52:42 +0200

> The dm9000 driver requests a shared interrupt but doesn't return
> IRQ_NONE when the device didn't generate the interrupt. This could lead
> to the other devices sharing the irq never getting an interrupt. This
> patch makes the routine return IRQ_NONE for the path where no work was
> done.
> 
> Signed-off-by: Daniel Morsing <daniel.morsing@gmail.com>
> Cc: stable@kernel.org

Applied.
