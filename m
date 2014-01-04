From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 08/11] ixgbe: Add Live Error Recovery
 configuration option
Date: Fri, 03 Jan 2014 20:43:21 -0500 (EST)
Message-ID: <20140103.204321.1052262695919537222.davem@davemloft.net>
References: <1388726310-2996-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1388726310-2996-9-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mark.d.rustad@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, bhutchings@solarflare.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35686 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753967AbaADBnZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 20:43:25 -0500
In-Reply-To: <1388726310-2996-9-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu,  2 Jan 2014 21:18:27 -0800

> From: Mark Rustad <mark.d.rustad@intel.com>
> 
> CONFIG_IXGBE_LER is added to control LER, Live Error Recovery,
> support. This avoids possible crashes in the driver when a device
> is suddenly removed, which is possible in Thunderbolt and other
> environments. Turning this off will save a little CPU utilization.
> 
> Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Compared to the cost of the MMIO register accesses themselves,
the cost of these checks will be negligible.

I also can't think of any distribution which would not enable
this option, so it's basically pointless.

Please remove it and just enable this new code unconditionally.
