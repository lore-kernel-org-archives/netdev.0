From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/2] ixgbe: Fix receive on real device when
 VLANs are configured
Date: Thu, 13 Aug 2009 20:14:19 -0700 (PDT)
Message-ID: <20090813.201419.02548406.davem@davemloft.net>
References: <20090814000929.20911.77027.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, lucy.liu@intel.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34458
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754450AbZHNDOJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 23:14:09 -0400
In-Reply-To: <20090814000929.20911.77027.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 13 Aug 2009 17:09:38 -0700

> From: Lucy Liu <lucy.liu@intel.com>
> 
> Traffic received with a priority tag (VID = 0) and non-zero priority value was
> incorrectly handled by the VLAN packet code path due to a check on zero for
> the whole VLAN tag instead of just the VID.
> 
> This patch masked out the priority field when checking the vlan tag for
> received VLAN packets.
> 
> Signed-off-by: Lucy Liu <lucy.liu@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
