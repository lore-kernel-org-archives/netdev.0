From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/3] ixgbe: Properly disable packet split
 per-ring when globally disabled
Date: Mon, 14 Sep 2009 17:08:30 -0700 (PDT)
Message-ID: <20090914.170830.108659301.davem@davemloft.net>
References: <20090914174659.4560.28814.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com, donald.c.skidmore@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58901
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757609AbZIOAIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 20:08:14 -0400
In-Reply-To: <20090914174659.4560.28814.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 14 Sep 2009 10:47:27 -0700

> From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> 
> The packet split feature was recently moved out of the adapter-wide flags
> feature field and into a per-Rx ring feature field.  In the process, packet
> split isn't properly disabled in the Rx ring if the adapter has it globally
> disabled, followed by a device reset.
> 
> This won't impact the driver today, since it's always in packet split mode.
> However, this will prevent any pitfalls if someone disables packet split on
> the adapter in the future and doesn't disable it in each ring.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>

Applied.
