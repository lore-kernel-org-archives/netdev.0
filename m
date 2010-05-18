From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r6040: fix link checking with switches
Date: Mon, 17 May 2010 22:48:49 -0700 (PDT)
Message-ID: <20100517.224849.135543081.davem@davemloft.net>
References: <201005161430.57429.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43888
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755127Ab0ERFsk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 01:48:40 -0400
In-Reply-To: <201005161430.57429.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Sun, 16 May 2010 14:30:56 +0200

> The current link checking logic only works for one port, which is not correct
> for swiches were multiple ports can have different link status. As a result
> we would only check for link status on port 1 of the switch. Move the calls
> to mii_check_media in r6040_timer which will be polling a single PHY chip
> correctly and assume link is up for switches.
> 
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

Applied.
