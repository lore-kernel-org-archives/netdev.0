From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/6] e1000e: 82577/8/9 issues with device in Sx
Date: Wed, 22 Sep 2010 21:10:47 -0700 (PDT)
Message-ID: <20100922.211047.27803503.davem@davemloft.net>
References: <20100923031432.10976.81909.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40225
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750786Ab0IWEK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 00:10:27 -0400
In-Reply-To: <20100923031432.10976.81909.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 22 Sep 2010 20:15:08 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> When going to Sx, disable gigabit in PHY (e1000_oem_bits_config_ich8lan)
> in addition to the MAC before configuring PHY wakeup otherwise the PHY
> configuration writes might be missed.  Also write the LED configuration
> and SMBus address to the PHY registers (e1000_oem_bits_config_ich8lan and
> e1000_write_smbus_addr, respectively).  The reset is no longer needed
> since re-auto-negotiation is forced in e1000_oem_bits_config_ich8lan and
> leaving it in causes issues with auto-negotiating the link.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
