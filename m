From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/2] [RFC] NET: Implement a standard ndev_printk family
Date: Mon, 11 Jun 2007 15:24:45 -0700
Message-ID: <1181600685.6020.20.camel@localhost>
References: <20070611213721.23014.4812.stgit@localhost.localdomain>
	 <1181598880.6020.8.camel@localhost>  <466DC657.2030401@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, davem@davemloft.net,
	arjan@linux.intel.com, shemminger@linux-foundation.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:4255 "EHLO Perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751180AbXFKWYs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2007 18:24:48 -0400
In-Reply-To: <466DC657.2030401@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-06-11 at 15:01 -0700, Kok, Auke wrote:
> > msg_enable is more frequently defined in drivers/net as u32 not int.
> yes, we're only using the bottom 15 bits anyway, but the net_device struct 
> consistently uses 'int' style members, leaving it up to the compiler to pick an 
> appropriate size for each arch. That was the reason I chose int here.

I guess I'm from a "don't be larger than necessary" school.

As it's a bitfield and not a boolean, it should be unsigned.
Perhaps it could also be a good time to rename it to something
like netif_enabled_msgs?

