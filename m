From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] net/smsc911x: Check if PHY is in operational
 mode before software reset
Date: Tue, 03 Jan 2012 20:24:33 -0500 (EST)
Message-ID: <20120103.202433.812126500710199359.davem@davemloft.net>
References: <1325633779-6159-1-git-send-email-javier@dowhile0.org>
	<1325633779-6159-2-git-send-email-javier@dowhile0.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@smsc.com, eballetbo@iseebcn.com,
	ben@decadent.org.uk, netdev@vger.kernel.org
To: javier@dowhile0.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45499 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754125Ab2ADBYm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 20:24:42 -0500
In-Reply-To: <1325633779-6159-2-git-send-email-javier@dowhile0.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Javier Martinez Canillas <javier@dowhile0.org>
Date: Wed,  4 Jan 2012 00:36:19 +0100

> SMSC LAN generation 4 chips integrate an IEEE 802.3 ethernet physical layer.
> The PHY driver for this integrated chip enable an energy detect power-down mode.
> When the PHY is in a power-down mode, it prevents the MAC portion chip to be
> software reseted.
> 
> That means that if we compile the kernel with the configuration option SMSC_PHY
> enabled and try to bring the network interface up without an cable plug-ed the
> PHY will be in a low power mode and the software reset will fail returning -EIO
> to user-space:
> 
> root@igep00x0:~# ifconfig eth0 up
> ifconfig: SIOCSIFFLAGS: Input/output error
> 
> This patch disable the energy detect power-down mode before trying to software
> reset the LAN chip and re-enables after it was reseted successfully.
> 
> Signed-off-by: Javier Martinez Canillas <javier@dowhile0.org>

Applied.
