From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/3] ixgbe: fix panic when shutting down system
 with WoL enabled
Date: Tue, 29 Jun 2010 23:15:07 -0700 (PDT)
Message-ID: <20100629.231507.26942433.davem@davemloft.net>
References: <20100630042739.8925.24962.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	andy@greyhouse.net, jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59126
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752237Ab0F3GOy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 02:14:54 -0400
In-Reply-To: <20100630042739.8925.24962.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 29 Jun 2010 21:28:12 -0700

> From: Andy Gospodarek <andy@greyhouse.net>
> 
> This patch added to 2.6.34:
> 
> 	commit 5f6c01819979afbfec7e0b15fe52371b8eed87e8
> 	Author: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 	Date:   Wed Apr 14 16:04:23 2010 -0700
> 
> 	    ixgbe: fix bug with vlan strip in promsic mode
> 
> among other things added a function called ixgbe_vlan_filter_enable.
> This new function wants to access and set some rx_ring parameters, but
> adapter->rx_ring has already been freed.  This simply moves the free
> until after the access and makes __ixgbe_shutdown look more like
> ixgbe_remove.
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
