From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] restore netdev_priv optimization (planb)
Date: Fri, 17 Aug 2007 18:30:08 -0700 (PDT)
Message-ID: <20070817.183008.38712695.davem@davemloft.net>
References: <20070817174909.5e890ad6@freepuppy.rosehill.hemminger.net>
	<20070817.180006.98552435.davem@davemloft.net>
	<46C64995.4030401@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: auke-jan.h.kok@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43588
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755353AbXHRBaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 21:30:09 -0400
In-Reply-To: <46C64995.4030401@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Date: Fri, 17 Aug 2007 18:21:25 -0700

> this sounds highly optimistic ("64 queues is enough for everyone"?)
> and probably will be quickly outdated by both hardware and demand...

As such drivers appear in the tree we can adjust the value.

Even the most aggressively multi-queued virtualization and 10GB
ethernet chips I am aware of, both in production and in development,
do not exceed this limit.

Since you think this is worth complaining about, you must know of some
exceptions? :-)

