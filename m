From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phy/micrel: KSZ8031RNL RMII clock reconfiguration bug
Date: Tue, 14 Oct 2014 12:41:17 -0400 (EDT)
Message-ID: <20141014.124117.827382744603557177.davem@davemloft.net>
References: <1412866094-4972-1-git-send-email-bth@kamstrup.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
	s.hauer@pengutronix.de, bruno.thomsen@gmail.com
To: bth@kamstrup.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42472 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752580AbaJNQlU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 12:41:20 -0400
In-Reply-To: <1412866094-4972-1-git-send-email-bth@kamstrup.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruno Thomsen <bth@kamstrup.dk>
Date: Thu, 9 Oct 2014 16:48:14 +0200

> Bug: Unable to send and receive Ethernet packets with Micrel PHY.
> 
> Affected devices:
> KSZ8031RNL (commercial temp)
> KSZ8031RNLI (industrial temp)
> 
> Description:
> PHY device is correctly detected during probe.
> PHY power-up default is 25MHz crystal clock input
> and output 50MHz RMII clock to MAC.
> Reconfiguration of PHY to input 50MHz RMII clock from MAC
> causes PHY to become unresponsive if clock source is changed
> after Operation Mode Strap Override (OMSO) register setup.
> 
> Cause:
> Long lead times on parts where clock setup match circuit design
> forces the usage of similar parts with wrong default setup.
> 
> Solution:
> Swapped KSZ8031 register setup and added phy_write return code validation.
> 
> Tested with Freescale i.MX28 Fast Ethernet Controler (fec).
> 
> Signed-off-by: Bruno Thomsen <bth@kamstrup.dk>

Applied, thank you.
