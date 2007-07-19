From: Jeff Garzik <jeff@garzik.org>
Subject: Re: ANNOUNCE: igb: Intel 82575 Gigabit Ethernet driver (PCI-Express)
Date: Wed, 18 Jul 2007 23:00:39 -0400
Message-ID: <469ED3D7.6040905@garzik.org>
References: <46980ADA.5050104@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:35139 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759332AbXGSDAm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2007 23:00:42 -0400
In-Reply-To: <46980ADA.5050104@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> 
> 
> All,
> 
> We are pleased to announce a new Gigabit Ethernet product and its driver 
> to the
> linux community. This product is the Intel(R) 82575 Gigabit Ethernet 
> adapter
> family. Physical adapters will be available to the public soon. These 
> adapters
> come in 2- and 4-port versions (copper PHY) currently. Other variants 
> will be
> available later.
> 
> The 82575 chipset supports significantly different features that warrant 
> a new
> driver. The descriptor format is (just like the ixgbe driver) different. 
> The
> device can use multiple MSI-X vectors and multiple queues for both send and
> receive. This allows us to optimize some of the driver code specifically 
> as well
> compared to the e1000-supported devices.
> 
> This driver was forked from e1000 several months ago and extensively 
> reworked
> and cleaned up since. The driver was also tested on several platforms in 
> our
> validation labs.
> 
> Allthough some of the codebase is currently shared with the e1000 driver 
> (this
> igb driver has a copy of that code where needed), we realize that many 
> of the
> changes that we are discussing for e1000 (the pci-express adapters that 
> e1000
> supports particularly) will also apply to this driver. However, since 
> this is a
> completely new driver that is relatively free of all old NIC support, we 
> feel
> that it is currently the right time to post this driver.
> 
> Unfortunately, the patch to insert this driver is too large to send to 
> netdev. I
> have therefore posted the patch on http:
> 
>      http://foo-projects.org/~sofar/igb.patch       [558K]
>      http://foo-projects.org/~sofar/igb.patch.bz2   [98K]

Just took a look at this.

This has the same problem as in the other thread -- huge internal API -- 
except this time, the problem is emphasized by the fact that the 
majority of the API hooks only have a single user, making each hook and 
API entry point demonstrably useless overhead.

Please remove the useless internal API and resubmit.

PLEASE take a look at how bnx2 and tg3 are structured.

	Jeff



