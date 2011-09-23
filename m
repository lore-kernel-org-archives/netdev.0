From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 01/02] ixgb: eliminate checkstack warnings
Date: Fri, 23 Sep 2011 13:56:12 -0400 (EDT)
Message-ID: <20110923.135612.1546317832418041651.davem@davemloft.net>
References: <1316779890-32436-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41500 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750762Ab1IWR4R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2011 13:56:17 -0400
In-Reply-To: <1316779890-32436-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 23 Sep 2011 05:11:29 -0700

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> Really trivial fix, use kmalloc/kfree instead of stack space.
> use static const instead of const to further reduce stack usage.
> 
> V2: reflect changes suggested by Joe Perches
> 
> before:
> [jbrandeb@jbrandeb-mobl2 linux-2.6]$ make checkstack|grep '\[ixgb\]'
> 0x00000fc1 ixgb_set_multi [ixgb]:                       768
> 0x00001031 ixgb_set_multi [ixgb]:                       768
> 0x000010f2 ixgb_set_multi [ixgb]:                       768
> 0x061c ixgb_check_options [ixgb]:                       448
> 0x09c3 ixgb_check_options [ixgb]:                       448
> 0x0000649e ixgb_set_ringparam [ixgb]:                   192
> 0x0000130d ixgb_xmit_frame [ixgb]:                      184
> 0x000019e0 ixgb_xmit_frame [ixgb]:                      184
> 0x00002267 ixgb_clean [ixgb]:                           152
> 0x00002673 ixgb_clean [ixgb]:                           152
> 
> after:
> 0x000064ee ixgb_set_ringparam [ixgb]:                   192
> 0x0000135d ixgb_xmit_frame [ixgb]:                      184
> 0x00001a30 ixgb_xmit_frame [ixgb]:                      184
> 0x000022b7 ixgb_clean [ixgb]:                           152
> 0x000026c3 ixgb_clean [ixgb]:                           152
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
