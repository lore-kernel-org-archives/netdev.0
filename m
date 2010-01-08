From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 4/5] ixgbe: Add Flow Director
 configuration support as a mod parameter
Date: Fri, 08 Jan 2010 00:24:49 -0800 (PST)
Message-ID: <20100108.002449.190520102.davem@davemloft.net>
References: <20100107044741.28605.31414.stgit@localhost.localdomain>
	<20100107044928.28605.62132.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com, deri@ntop.org,
	joseph.gasparakis@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58129
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751807Ab0AHIYk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 03:24:40 -0500
In-Reply-To: <20100107044928.28605.62132.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 06 Jan 2010 20:49:29 -0800

> From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> 
> This patch adds the ability to change the Flow Director behavior in
> ixgbe through a module parameter.  ixgbe, on 82599 hardware, can support
> hash-based or perfect-based filtering.  It currently uses hash-based, and
> should have a knob to enable perfect-based filtering.
> 
> This will be used in conjunction with the ethtool n-tuple filter
> programming support.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Use a generic ethtool boolean flag or similar, not "yet another
different-in-every-driver" module parameter please.
