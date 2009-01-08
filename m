From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] r6040: warn about MAC address being unset
Date: Thu, 08 Jan 2009 11:03:29 -0800 (PST)
Message-ID: <20090108.110329.148510077.davem@davemloft.net>
References: <200901071740.42130.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42282
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758756AbZAHTD2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 14:03:28 -0500
In-Reply-To: <200901071740.42130.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Wed, 7 Jan 2009 17:40:41 +0100

> r6040: warn about MAC address being unset
> 
> Some bootloader/BIOSes do not set the MAC
> address, warn about that.
> 
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

Applied.

Even better behavior would be to use a random ethernet address after
emitting the warning, so that the user still has a usable interface.

See the random_ether_addr() interface and how many other net drivers
make use of it in situations nearly identical to this one.
