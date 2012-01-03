From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net/smsc911x: Check if PHY is in operational mode
 before software reset
Date: Tue, 03 Jan 2012 13:46:47 -0500 (EST)
Message-ID: <20120103.134647.1029494174636172958.davem@davemloft.net>
References: <1325524131-14585-1-git-send-email-martinez.javier@gmail.com>
	<1325524131-14585-2-git-send-email-martinez.javier@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@smsc.com, ben@decadent.org.uk,
	eballetbo@iseebcn.com, netdev@vger.kernel.org
To: martinez.javier@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41403 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754537Ab2ACSq5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 13:46:57 -0500
In-Reply-To: <1325524131-14585-2-git-send-email-martinez.javier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Javier Martinez Canillas <martinez.javier@gmail.com>
Date: Mon,  2 Jan 2012 18:08:51 +0100

> +	/* If energy is detected the PHY is already awake so is not necessary
> +	 * to disable the energy detect power-down mode. */
 ...
> +	/* LAN9210/LAN9211/LAN9220/LAN9221 chips have an internal PHY that
> +	 * are initialized in a Energy Detect Power-Down mode that prevents
> +	 * the MAC chip to be software reseted. So we have to wakeup the PHY
> +	 * before */

Format these comments correctly:

	/* Like this.
	 * See?
	 */

	/* Not like this.
	 * Ok? */
