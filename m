From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] ixgbe: fix for real_num_tx_queues update issue
Date: Fri, 19 Mar 2010 21:06:37 -0700 (PDT)
Message-ID: <20100319.210637.112617278.davem@davemloft.net>
References: <20100319143242.10230.9964.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, vasu.dev@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44617
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750822Ab0CTEGP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Mar 2010 00:06:15 -0400
In-Reply-To: <20100319143242.10230.9964.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 19 Mar 2010 07:33:10 -0700

> From: Vasu Dev <vasu.dev@intel.com>
> 
> Currently netdev_features_change is called before fcoe tx queues
> setup is done, so this patch moves calling of netdev_features_change
> after tx queues setup is done in ixgbe_init_interrupt_scheme, so
> that real_num_tx_queues is updated correctly on each fcoe enable
> or disable.
> 
> This allows additional fcoe queues updated correctly in vlan driver
> for their correct queue selection.
> 
> Signed-off-by: Vasu Dev <vasu.dev@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
