From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 6/6] e1000e: 82579 do not gate auto config of
 PHY by hardware during nominal use
Date: Wed, 22 Sep 2010 21:11:15 -0700 (PDT)
Message-ID: <20100922.211115.52176292.davem@davemloft.net>
References: <20100923031432.10976.81909.stgit@localhost.localdomain>
	<20100923031700.10976.38.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53070
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751013Ab0IWEK4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 00:10:56 -0400
In-Reply-To: <20100923031700.10976.38.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 22 Sep 2010 20:17:01 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> For non-managed versions of 82579, set the bit that prevents the hardware
> from automatically configuring the PHY after resets only when the driver
> performs a reset, clear the bit after resets.  This is so the hardware can
> configure the PHY automatically when the part is reset in a manner that is
> not controlled by the driver (e.g. in a virtual environment via PCI FLR)
> otherwise the PHY will be mis-configured causing issues such as failing to
> link at 1000Mbps.
> For managed versions of 82579, keep the previous behavior since the
> manageability firmware will handle the PHY configuration.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
