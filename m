From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ucc_geth: fix ucc halt problem in half duplex mode
Date: Sun, 28 Nov 2010 18:37:26 -0800 (PST)
Message-ID: <20101128.183726.115930841.davem@davemloft.net>
References: <1290763798-22844-1-git-send-email-leoli@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	jdboyer@media5corp.com, Andreas.Schmitz@riedel.net,
	avorontsov@ru.mvista.com
To: leoli@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51187
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754406Ab0K2ChB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Nov 2010 21:37:01 -0500
In-Reply-To: <1290763798-22844-1-git-send-email-leoli@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Yang <leoli@freescale.com>
Date: Fri, 26 Nov 2010 17:29:58 +0800

> In commit 58933c64(ucc_geth: Fix the wrong the Rx/Tx FIFO size),
> the UCC_GETH_UTFTT_INIT is set to 512 based on the recommendation
> of the QE Reference Manual.  But that will sometimes cause tx halt
> while working in half duplex mode.
> 
> According to errata draft QE_GENERAL-A003(High Tx Virtual FIFO
> threshold size can cause UCC to halt), setting UTFTT less than
> [(UTFS x (M - 8)/M) - 128] will prevent this from happening
> (M is the minimum buffer size).
> 
> The patch changes UTFTT back to 256.
> 
> Signed-off-by: Li Yang <leoli@freescale.com>
> Cc: Jean-Denis Boyer <jdboyer@media5corp.com>
> Cc: Andreas Schmitz <Andreas.Schmitz@riedel.net>
> Cc: Anton Vorontsov <avorontsov@ru.mvista.com>

Applied, thank you.
