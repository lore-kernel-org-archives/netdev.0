From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: fec: make sure to init MAC address
Date: Mon, 31 Mar 2014 16:34:49 -0400 (EDT)
Message-ID: <20140331.163449.1819672500427251304.davem@davemloft.net>
References: <1396207928-2636-1-git-send-email-dev@lynxeye.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel@pengutronix.de,
	l.stach@pengutronix.de
To: dev@lynxeye.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42988 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750777AbaCaUev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 16:34:51 -0400
In-Reply-To: <1396207928-2636-1-git-send-email-dev@lynxeye.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lucas Stach <dev@lynxeye.de>
Date: Sun, 30 Mar 2014 21:32:08 +0200

> From: Lucas Stach <l.stach@pengutronix.de>
> 
> Though we made sure to acquire a valid MAC for
> the netdevice we never actually programmed it
> into the hardware.
> So if the bootloader did not set the MAC,
> network operation would only work if userspace
> explicitly asked to transfer the MAC to hardware.
> 
> Signed-off-by: Lucas Stach <l.stach@pengutronix.de>

Applied, thank you.
