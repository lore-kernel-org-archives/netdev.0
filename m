From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [RFC] restore netdev_priv optimization (planb)
Date: Fri, 17 Aug 2007 18:48:06 -0700
Message-ID: <46C64FD6.6030902@intel.com>
References: <20070817174909.5e890ad6@freepuppy.rosehill.hemminger.net>	<20070817.180006.98552435.davem@davemloft.net>	<46C64995.4030401@intel.com> <20070817.183008.38712695.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:52799 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750787AbXHRBsJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Aug 2007 21:48:09 -0400
In-Reply-To: <20070817.183008.38712695.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: "Kok, Auke" <auke-jan.h.kok@intel.com>
> Date: Fri, 17 Aug 2007 18:21:25 -0700
> 
>> this sounds highly optimistic ("64 queues is enough for everyone"?)
>> and probably will be quickly outdated by both hardware and demand...
> 
> As such drivers appear in the tree we can adjust the value.
> 
> Even the most aggressively multi-queued virtualization and 10GB
> ethernet chips I am aware of, both in production and in development,
> do not exceed this limit.
> 
> Since you think this is worth complaining about, you must know of some
> exceptions? :-)

I actually don't, but I assume that demand for queues will quickly increase once 
the feature becomes available. e.g. in e1000 hardware (pci-e) we support 2, and 
this is really old hardware already (laugh), 82575 has 4.

the ixgbe driver me and Ayyappan posted already supports 64 rx queues and 32 tx...

I can only expect the next generation to take a bigger jump and implement at 
least 128 queues... :)

Auke
