From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/4] ixgbe: fix regression on some 82598
 adapters
Date: Fri, 03 Jul 2009 19:12:11 -0700 (PDT)
Message-ID: <20090703.191211.185827358.davem@davemloft.net>
References: <20090702225012.22746.57218.stgit@localhost.localdomain>
	<20090702225031.22746.74206.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com, donald.c.skidmore@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36291
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757062AbZGDCMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2009 22:12:05 -0400
In-Reply-To: <20090702225031.22746.74206.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 02 Jul 2009 15:50:31 -0700

> From: Don Skidmore <donald.c.skidmore@intel.com>
> 
> The change to check the SFP+ module again on open() was
> causing the XFP (non-SFP+) adapters to be rejected. We
> only want to try and re-identify the SFP+ module if the
> original probe found that this device was an SFP+ device.
> So for this code path (driver loaded with SFP module, module
> inserted, ifconfig up of the device) the type will be
> ixgbe_phy_unknown for an unidentified SFP+ module.  So we
> only check if that is the case.
> 
> This problem also shows up on Copper devices.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
