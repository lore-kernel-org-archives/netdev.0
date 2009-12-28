From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] phylib: Properly reinitialize PHYs after
 hibernation
Date: Sun, 27 Dec 2009 21:55:04 -0800 (PST)
Message-ID: <20091227.215504.71112983.davem@davemloft.net>
References: <20091222221451.GB9268@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, leoli@freescale.com,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	linux-pm@lists.linux-foundation.org
To: cbouatmailru@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45882
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751472AbZL1FzC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2009 00:55:02 -0500
In-Reply-To: <20091222221451.GB9268@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Vorontsov <cbouatmailru@gmail.com>
Date: Wed, 23 Dec 2009 01:14:51 +0300

> Since hibernation assumes power loss, we should fully reinitialize
> PHYs (including platform fixups), as if PHYs were just attached.
> 
> This patch factors phy_init_hw() out of phy_attach_direct(), then
> converts mdio_bus to dev_pm_ops and adds an appropriate restore()
> callback.
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>

Applied.
