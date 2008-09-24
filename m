From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/9] [ETH]: Start net device with carrier down
Date: Wed, 24 Sep 2008 15:24:57 -0700 (PDT)
Message-ID: <20080924.152457.13104395.davem@davemloft.net>
References: <e665d9ff8b50796ce65c503604453056217bfc8a.1221537369.git.tpiepho@freescale.com>
	<ebb4b9e34a594b9ca0fda9042bfa12bff9e9fac2.1221537369.git.tpiepho@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, afleming@freescale.com
To: tpiepho@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35067
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751084AbYIXWZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 18:25:10 -0400
In-Reply-To: <ebb4b9e34a594b9ca0fda9042bfa12bff9e9fac2.1221537369.git.tpiepho@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Trent Piepho <tpiepho@freescale.com>
Date: Wed, 24 Sep 2008 14:20:55 -0700

> The problem is that when the device is first created and opened, the state
> bit indicating the carrier is down isn't set, i.e. the state is wrong.
> When the carrier comes up for the first time no netlink event is sent,
> since the device state indicated the carrier was already up.

It works properly if the device driver does as it is supposed to,
which is invoke netif_carrier_off() in it's ->open() method in this
situation.

Please fix the drivers where this is not happening.
