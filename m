From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: ptp: fix NULL pointer dereference if
 ptp_clock is not set
Date: Wed, 22 Oct 2014 17:48:41 -0400 (EDT)
Message-ID: <20141022.174841.909151462884445312.davem@davemloft.net>
References: <1413988475-6565-1-git-send-email-p.zabel@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: b45643@freescale.com, netdev@vger.kernel.org
To: p.zabel@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33590 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933237AbaJVVsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 17:48:45 -0400
In-Reply-To: <1413988475-6565-1-git-send-email-p.zabel@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philipp Zabel <p.zabel@pengutronix.de>
Date: Wed, 22 Oct 2014 16:34:35 +0200

> Since commit 278d24047891 (net: fec: ptp: Enable PPS output based on ptp clock)
> fec_enet_interrupt calls fec_ptp_check_pps_event unconditionally, which calls
> into ptp_clock_event. If fep->ptp_clock is NULL, ptp_clock_event tries to
> dereference the NULL pointer.
> Since on i.MX53 fep->bufdesc_ex is not set, fec_ptp_init is never called,
> and fep->ptp_clock is NULL, which reliably causes a kernel panic.
> 
> This patch adds a check for fep->ptp_clock == NULL in fec_enet_interrupt.
> 
> Signed-off-by: Philipp Zabel <p.zabel@pengutronix.de>

Applied, thank you.
