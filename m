From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] ixgbe: fix bug with vlan strip in promsic
 mode
Date: Wed, 14 Apr 2010 16:04:37 -0700 (PDT)
Message-ID: <20100414.160437.147103882.davem@davemloft.net>
References: <20100414221015.11752.42490.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43468
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756057Ab0DNXEd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 19:04:33 -0400
In-Reply-To: <20100414221015.11752.42490.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 14 Apr 2010 15:11:12 -0700

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> The ixgbe driver was setting up 82598 hardware correctly, so that
> when promiscuous mode was enabled hardware stripping was turned
> off.  But on 82599 the logic to disable/enable hardware stripping
> is different, and the code was not updated correctly when the
> hardware vlan stripping was enabled as default.
> 
> This change comprises the creation of two new helper functions
> and calling them from the right locations to disable and enable
> hardware stripping of vlan tags at appropriate times.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, for real this time! :-)

Thanks.
