From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/6] e1000e: 82579 SMBus address and LEDs
 incorrect after device reset
Date: Wed, 22 Sep 2010 21:10:53 -0700 (PDT)
Message-ID: <20100922.211053.191396479.davem@davemloft.net>
References: <20100923031432.10976.81909.stgit@localhost.localdomain>
	<20100923031532.10976.41477.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40230
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750940Ab0IWEKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 00:10:33 -0400
In-Reply-To: <20100923031532.10976.41477.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 22 Sep 2010 20:15:33 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> Since the hardware is prevented from performing automatic PHY configuration
> (the driver does it instead), the OEM_WRITE_ENABLE bit in the EXTCNF_CTRL
> register will not get cleared preventing the SMBus address and the LED
> configuration to be written to the PHY registers.  On 82579, do not check
> the OEM_WRITE_ENABLE bit.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
