From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: Fix RXICr/TXICr programming for multi-queue
 mode
Date: Thu, 28 Jun 2012 16:57:55 -0700 (PDT)
Message-ID: <20120628.165755.2122030720581045253.davem@davemloft.net>
References: <1340894453-28556-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57604 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752282Ab2F1X54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 19:57:56 -0400
In-Reply-To: <1340894453-28556-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Thu, 28 Jun 2012 17:40:53 +0300

> The correct behavior is to program the interrupt coalescing regs
> (RXICr/TXICr) in accordance with the Rx/Tx Q's "rx/txcoalescing"
> flag. That is, if the coalescing flag is 0 for a given Rx/Tx queue
> then the corresponding coalescing register should be cleared.
> This behavior is correctly implemented for the single-queue mode
> (SQ_SG_MODE), but not for the multi-queue mode (MQ_MG_MODE).
> This fixes the later case.
> 
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>

Applied, thanks.
