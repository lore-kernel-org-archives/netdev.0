From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/2] igb.txt: Add igb documentation
Date: Wed, 04 Aug 2010 03:34:34 +0100
Message-ID: <1280889274.13192.565.camel@localhost>
References: <20100804001429.6571.95116.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, gospo@redhat.com, bphilips@novell.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:5958 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756860Ab0HDCek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 22:34:40 -0400
In-Reply-To: <20100804001429.6571.95116.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-08-03 at 17:15 -0700, Jeff Kirsher wrote:
[...]
> +  Jumbo Frames
> +  ------------
> +  Jumbo Frames support is enabled by changing the MTU to a value larger than
> +  the default of 1500.  Use the ifconfig command to increase the MTU size.
> +  For example:
> +
> +       ifconfig eth<x> mtu 9000 up
> +
> +  This setting is not saved across reboots.  

Not igb-specific.

[...]
> +  Ethtool
> +  -------
> +  The driver utilizes the ethtool interface for driver configuration and
> +  diagnostics, as well as displaying statistical information.  Ethtool
> +  version 3.0 or later is required for this functionality, although we 
> +  strongly recommend downloading the latest version at:
> +
> +  http://sourceforge.net/projects/gkernel.

Not igb-specific, and seriously - 3.0?

> +  Enabling Wake on LAN* (WoL)
> +  ---------------------------
> +  WoL is configured through the Ethtool* utility. 

Not igb-specific.

[...]
> +  LRO
> +  ---
> +  Large Receive Offload (LRO) is a technique for increasing inbound throughput
> +  of high-bandwidth network connections by reducing CPU overhead. It works by
> +  aggregating multiple incoming packets from a single stream into a larger 
> +  buffer before they are passed higher up the networking stack, thus reducing
> +  the number of packets that have to be processed. LRO combines multiple 
> +  Ethernet frames into a single receive in the stack, thereby potentially 
> +  decreasing CPU utilization for receives.

Not igb-specific.

> +  NOTE: LRO requires 2.6.24 or later kernel version.
[...]

Which is irrelevant to an in-tree driver.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

