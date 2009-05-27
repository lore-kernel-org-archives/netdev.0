From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/4] ixgbe: fix 82598 SFP initialization
 after driver load.
Date: Tue, 26 May 2009 20:40:57 -0700 (PDT)
Message-ID: <20090526.204057.193339971.davem@davemloft.net>
References: <20090527005403.28535.8727.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, donald.c.skidmore@intel.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55753
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756890AbZE0Dk6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 23:40:58 -0400
In-Reply-To: <20090527005403.28535.8727.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 26 May 2009 17:54:04 -0700

> If we loaded the driver with out a SFP module plugged in it would
> leave it in a state that make it later unable to link when a module
> was plugged in.  This patch corrects that by:
> 
> ixgbe_probe() - moving the check for IXGBE_ERR_SFP_NOT_PRESENT from
> after get_invariants() to after reset_hw() as now reset_hw() is
> where this condition will be indentified.
> 
> ixgbe_reset_hw_82598() - Enable this function to now return
> IXGBE_ERR_SFP_NOT_PRESENT.
> 
> ixgbe_identify_sfp_module_generic() - This where the lack of SFP
> module is detected.  Modifications are added to allow a different
> return value for modules that just haven't been plugged in yet.
> 
> Other functions were updated to allow correct logging.
> 
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
