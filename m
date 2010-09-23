From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] e1000/e1000e/igb/ixgb/ixgbe: set
 NETIF_F_HIGHDMA for VLAN feature flags
Date: Wed, 22 Sep 2010 21:20:23 -0700 (PDT)
Message-ID: <20100922.212023.91330415.davem@davemloft.net>
References: <20100923035755.11561.14170.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	yi.zou@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52580
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752438Ab0IWEUE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 00:20:04 -0400
In-Reply-To: <20100923035755.11561.14170.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 22 Sep 2010 20:57:58 -0700

> From: Yi Zou <yi.zou@intel.com>
> 
> If the netdev->features is set with NETIF_F_HIGHDMA, we should set the
> corresponding netdev->vlan_features as well to allow VLAN netdev created
> on top of the real netdev to be able to also benefit from HIGHDMA on 32bit
> system, reducing the performance hit that is caused by __skb_linearize(),
> particularly for large send. This is fixed in this patch for all Intel e1000,
> e1000e, igb, ixgbe, and ixgbe drivers since this should be beneficial
> to all devices supported by these drivers.
> 
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
