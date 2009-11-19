From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/3] ixgbe: Set MSI-X vectors to
 NOBALANCING and set affinity
Date: Wed, 18 Nov 2009 22:28:34 -0800 (PST)
Message-ID: <20091118.222834.01656318.davem@davemloft.net>
References: <1258573570.2780.14.camel@achroite.uk.solarflarecom.com>
	<20091118.115039.41419484.davem@davemloft.net>
	<1258593299.3103.0.camel@ppwaskie-mobl2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, jeffrey.t.kirsher@intel.com,
	gospo@redhat.com, netdev@vger.kernel.org
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49240
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751129AbZKSG2S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 01:28:18 -0500
In-Reply-To: <1258593299.3103.0.camel@ppwaskie-mobl2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Date: Wed, 18 Nov 2009 17:14:57 -0800

> We actually just submitted a patch that pairs our Rx queue 0 and Tx
> queue 0 (up until the number of queues) onto the same MSI-X
> interrupt.  Arjan had indicated though he'd still like to make
> irqbalance smart enough to distinguish Rx and Tx from one another,
> regardless if the drivers just move to queue pairs or not.  I don't
> care either way, since my queues are now paired.

Ok.
