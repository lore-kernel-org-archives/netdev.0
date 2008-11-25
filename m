From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phylib: Add Vitesse VSC8221 SGMII PHY
Date: Tue, 25 Nov 2008 01:00:57 -0800 (PST)
Message-ID: <20081125.010057.17725446.davem@davemloft.net>
References: <1227569316-28242-1-git-send-email-tpiepho@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tpiepho@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34609
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751887AbYKYJA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 04:00:58 -0500
In-Reply-To: <1227569316-28242-1-git-send-email-tpiepho@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Trent Piepho <tpiepho@freescale.com>
Date: Mon, 24 Nov 2008 15:28:36 -0800

> PHY is mostly compatible with the existing VSC8244 PHY.  The init sequence
> is different and the interrupt mask lacks some bits present in the VSC8244.
> 
> Rather than making a copy of the existing VSC234x config_intr function and
> change one constant, I modify it to select the interrupt mask based on
> which driver is calling it.  This lets it be used by both drivers.
> 
> Signed-off-by: Trent Piepho <tpiepho@freescale.com>

Applied, thanks.
