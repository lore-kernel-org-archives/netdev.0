From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next] gianfar: Simplify MQ polling to avoid soft
 lockup
Date: Fri, 18 Oct 2013 15:55:09 -0400 (EDT)
Message-ID: <20131018.155509.1014087515327657926.davem@davemloft.net>
References: <1381759509-26882-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57937 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757695Ab3JRTzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 15:55:13 -0400
In-Reply-To: <1381759509-26882-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Mon, 14 Oct 2013 17:05:09 +0300

> Under certain low traffic conditions, the single core
> devices with multiple Rx/Tx queues (MQ mode) may reach
> soft lockup due to gfar_poll not returning in proper time.
> The following exception was obtained using iperf on a 100Mbit
> half-duplex link, for a p1010 single core device:
 ...
> To prevent this, the outer while() loop has been removed
> allowing gfar_poll() to return faster even if there's
> still budget left.  Also, there's no need to recompute
> the budget per Rx queue anymore.
> 
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>

Applied, thanks.
