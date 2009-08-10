From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/2] ixgbe: Pass rx_ring directly in
 ixgbe_configure_srrctl()
Date: Sun, 09 Aug 2009 21:53:22 -0700 (PDT)
Message-ID: <20090809.215322.159663598.davem@davemloft.net>
References: <20090806230514.28347.51172.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, yi.zou@intel.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50022
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752399AbZHJExM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2009 00:53:12 -0400
In-Reply-To: <20090806230514.28347.51172.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 06 Aug 2009 16:05:23 -0700

> From: Yi Zou <yi.zou@intel.com>
> 
> Instead of passing the register index of the corresponding rx_ring and find
> the way back to get to corresponding rx_ring in ixgbe_configure_srrctl(),
> simplify the function ixgbe_configure_srrctl() by passing the rx_ring into
> it. Then the register index for that rx_ring is already available from
> rx_ring->reg_idx.
> 
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
