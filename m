From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: ANNOUNCE: igb: Intel 82575 Gigabit Ethernet driver (PCI-Express)
Date: Fri, 13 Jul 2007 16:29:30 -0700
Message-ID: <46980ADA.5050104@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Auke Kok <auke-jan.h.kok@intel.com>
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:61462 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759696AbXGMX3b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jul 2007 19:29:31 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



All,

We are pleased to announce a new Gigabit Ethernet product and its driver to the
linux community. This product is the Intel(R) 82575 Gigabit Ethernet adapter
family. Physical adapters will be available to the public soon. These adapters
come in 2- and 4-port versions (copper PHY) currently. Other variants will be
available later.

The 82575 chipset supports significantly different features that warrant a new
driver. The descriptor format is (just like the ixgbe driver) different. The
device can use multiple MSI-X vectors and multiple queues for both send and
receive. This allows us to optimize some of the driver code specifically as well
compared to the e1000-supported devices.

This driver was forked from e1000 several months ago and extensively reworked
and cleaned up since. The driver was also tested on several platforms in our
validation labs.

Allthough some of the codebase is currently shared with the e1000 driver (this
igb driver has a copy of that code where needed), we realize that many of the
changes that we are discussing for e1000 (the pci-express adapters that e1000
supports particularly) will also apply to this driver. However, since this is a
completely new driver that is relatively free of all old NIC support, we feel
that it is currently the right time to post this driver.

Unfortunately, the patch to insert this driver is too large to send to netdev. I
have therefore posted the patch on http:

      http://foo-projects.org/~sofar/igb.patch       [558K]
      http://foo-projects.org/~sofar/igb.patch.bz2   [98K]

And also put up the patch in a git tree for those who want to pull:

      git-pull git://lost.foo-projects.org/~ahkok/git/linux-2.6 igb

Please review and provide comments!

Current issues:

There are several discussions ongoing about multiqueue and NAPI that also apply
to this driver, so several TODO items already exist (remove fake netdevs for
instance). As we get to these issues with the new e1000e and ixgbe driver, we
will try to address them in this igb driver as well, but feel free to raise them
early and now as well.


Thanks,

Auke Kok
