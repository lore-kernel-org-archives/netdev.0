From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next PATCH 11/11] ixgbe: Add documentation for the driver
Date: Sun, 15 Mar 2009 19:25:46 +0000
Message-ID: <1237145146.4209.45.camel@hashbaz.i.decadent.org.uk>
References: <20090314081229.4687.40245.stgit@lost.foo-projects.org>
	 <20090314081554.4687.58711.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:41710 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751379AbZCOTZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2009 15:25:52 -0400
In-Reply-To: <20090314081554.4687.58711.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-03-14 at 01:15 -0700, Jeff Kirsher wrote:
> From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> 
> Documentation for the ixgbe driver in the kernel docs area is missing.
> This adds that documentation.
[...]
> +2. Load the module:
> +
> +# modprobe ixgbe
> +
> +   The insmod command can be used if the full
> +   path to the driver module is specified.  For example:
> +
> +     insmod /lib/modules/<KERNEL VERSION>/kernel/drivers/net/ixgbe/ixgbe.ko
> +
> +   With 2.6 based kernels also make sure that older ixgbe drivers are
> +   removed from the kernel, before loading the new module:
> +
> +     rmmod ixgbe; modprobe ixgbe
> +
> +3. Assign an IP address to the interface by entering the following, where
> +   x is the interface number:
> +
> +     ifconfig ethx <IP_address>
> +
> +4. Verify that the interface works. Enter the following, where <IP_address>
> +   is the IP address for another machine on the same subnet as the interface
> +   that is being tested:
> +
> +     ping  <IP_address>
[...]

This is the same as for any network driver, so there is no point
including it in driver-specific documentation.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
