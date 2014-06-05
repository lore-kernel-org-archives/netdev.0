From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: Call netif_carrier_off() prior to registration
Date: Thu, 05 Jun 2014 15:04:16 -0700 (PDT)
Message-ID: <20140605.150416.1615019571569772686.davem@davemloft.net>
References: <1401836138-13253-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: claudiu.manoil@freescale.com, netdev@vger.kernel.org,
	fabio.estevam@freescale.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51277 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751884AbaFEWES (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 18:04:18 -0400
In-Reply-To: <1401836138-13253-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Tue,  3 Jun 2014 19:55:38 -0300

> From: Fabio Estevam <fabio.estevam@freescale.com>
> 
> Quoting David Miller:
> "At the moment you call register_netdev() the device is visible, notifications
> are sent to userspace, and userland tools can try to bring the interface up
> and see the incorrect link state, before you do the netif_carrier_off().
> 
> Said another way, between the register_netdev() and netif_carrier_off() call,
> userspace can see the device in an inconsistent state."
> 
> So call netif_carrier_off() prior to register_netdev().
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied, thank you.
