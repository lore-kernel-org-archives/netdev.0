From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [v2] net/fsl_pq_mdio: use spin_event_timeout() to poll
 the indicator register
Date: Mon, 09 Jul 2012 15:15:55 -0700 (PDT)
Message-ID: <20120709.151555.1777842329050058503.davem@davemloft.net>
References: <1341871056-6658-1-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, netdev@vger.kernel.org,
	jan.ceuleers@computer.org
To: timur@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59726 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754537Ab2GIWQC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 18:16:02 -0400
In-Reply-To: <1341871056-6658-1-git-send-email-timur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@freescale.com>
Date: Mon, 9 Jul 2012 16:57:36 -0500

> Macro spin_event_timeout() was designed for simple polling of hardware
> registers with a timeout, so use it when we poll the MIIMIND register.
> This allows us to return an error code instead of polling indefinitely.
> 
> Note that PHY_INIT_TIMEOUT is a count of loop iterations, so we can't use
> it for spin_event_timeout(), which asks for microseconds.
> 
> Signed-off-by: Timur Tabi <timur@freescale.com>

Applied to net-next, thanks.
