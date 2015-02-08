From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] amd-xgbe: Check per channel DMA interrupt use in
 main ISR
Date: Sat, 07 Feb 2015 22:45:45 -0800 (PST)
Message-ID: <20150207.224545.2294450094908030704.davem@davemloft.net>
References: <20150206011714.2507.45712.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47225 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751526AbbBHGpq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Feb 2015 01:45:46 -0500
In-Reply-To: <20150206011714.2507.45712.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Thu, 5 Feb 2015 19:17:14 -0600

> When using per channel DMA interrupts the transmit interrupt (TI) and the
> receive interrupt (RI) are masked off so as to not generate an interrupt
> to the main ISR. However, should another interrupt fire for the DMA channel
> that is handled by the main ISR the TI/RI bits can still be set. This
> will cause the wrong and uninitialized napi structure to be used causing a
> panic. Add a check to be sure per channel DMA interrupts are not enabled
> before acting on those bit flags.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>

Applied.
