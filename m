From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: RFC: igb: Intel 82575 gigabit ethernet driver (take #3)
Date: Thu, 10 Jan 2008 19:01:43 -0500
Message-ID: <4786B1E7.5030700@pobox.com>
References: <4786AB0C.6010202@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>,
	Arjan van de Ven <arjan@linux.intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33438 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754001AbYAKABt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2008 19:01:49 -0500
In-Reply-To: <4786AB0C.6010202@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kok, Auke wrote:
> All,
> 
> here is the third version of the igb (82575) ethernet controller driver. This
> driver was previously posted 2007-07-13 and 2007-12-11. Many comments received
> were addressed:
> 
> - removed indirection wrappers in the same way as e1000e and ixgbe.
> - cleaned up largely against sparse, checkpatch
> - removed module parameters and moved functionality to ethtool ioctls
> - new NAPI API rewrites
> - by default the driver runs in multiqueue mode with 2 to 40 RX queues enabled.
> 
> and specifically in this version:
> 
> - register macro's were condensed for readability
> - fixed namespace collisions by renaming functions to igb_*
> 
> Since the driver is still too large (allthough the patch shrunk from 558k to 416k
> to 407k, almost 38% of its size) to post to this list I am attaching the bzipped
> patch here. You can get the same driver alternatively from here:
> 
> http://foo-projects.org/~sofar/0001-igb-PCI-Express-82575-Gigabit-Ethernet-driver.patch
> [407k]
> http://foo-projects.org/~sofar/0001-igb-PCI-Express-82575-Gigabit-Ethernet-driver.patch.bz2
> [74k]
> 
> or through git:
>     git://lost.foo-projects.org/~ahkok/git/linux-2.6 #igb
> 
> 
> There are several concerns still open for this driver:
> - hardware code is still a large API. we're expecting more hardware to be
> supported by this driver in the future. The API has already been scrubbed but we
> anticipate that the remaining hooks will be used in the future.
> - The register defines are still named "E1000_" as they are mostly identical to
> the e1000 chipsets (igb register space is a superset of most recent e1000 register
> sets).

I think we can throw it into netdev#upstream if you're ready...

	Jeff




