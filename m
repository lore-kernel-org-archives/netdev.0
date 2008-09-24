From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/9] [ETH]: Start net device with carrier down
Date: Wed, 24 Sep 2008 15:25:33 -0700 (PDT)
Message-ID: <20080924.152533.175678382.davem@davemloft.net>
References: <e665d9ff8b50796ce65c503604453056217bfc8a.1221537369.git.tpiepho@freescale.com>
	<ebb4b9e34a594b9ca0fda9042bfa12bff9e9fac2.1221537369.git.tpiepho@freescale.com>
	<20080924143203.1eba6bbe@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tpiepho@freescale.com, netdev@vger.kernel.org,
	afleming@freescale.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40285
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751619AbYIXWZo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 18:25:44 -0400
In-Reply-To: <20080924143203.1eba6bbe@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 24 Sep 2008 14:32:03 -0700

> This breaks devices that never call netif_carrier_on.
> 
> Standard practice is to call netif_carrier_off after allocation but before
> register_netdev

Or in ->open()
