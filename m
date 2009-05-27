From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 4/4] ixgbe: Remove device ID 0x10d8
Date: Tue, 26 May 2009 20:40:17 -0700 (PDT)
Message-ID: <20090526.204017.32055021.davem@davemloft.net>
References: <20090527005403.28535.8727.stgit@localhost.localdomain>
	<20090527005502.28535.93314.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55750
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756575AbZE0DkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 23:40:18 -0400
In-Reply-To: <20090527005502.28535.93314.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 26 May 2009 17:55:02 -0700

> Device ID 0x10d8 is the default silicon device ID for 82599.  However, the
> device will not be functional without an EEPROM, so we want to prevent the
> driver from loading on the device.  Otherwise, the driver will load, but no
> PHY setup or PCIe setup will occur, causing the device to be unusable.  To
> prevent users from encountering this, just remove the device ID.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
