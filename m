From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/3] ixgbe: Fix checking TFCS register for
 TXOFF status when DCB is enabled
Date: Fri, 06 Nov 2009 20:34:06 -0800 (PST)
Message-ID: <20091106.203406.144302189.davem@davemloft.net>
References: <20091106225526.28063.83720.stgit@localhost.localdomain>
	<20091106225559.28063.467.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, yi.zou@intel.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46680
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760162AbZKGEdk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 23:33:40 -0500
In-Reply-To: <20091106225559.28063.467.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 06 Nov 2009 14:56:00 -0800

> From: Yi Zou <yi.zou@intel.com>
> 
> When DCB is enabled, the ixgbe_check_tx_hang() should check the corresponding
> TC's TXOFF in TFCS based on the TC that the tx ring belongs to. Adds a
> function to map from the tx_ring hw reg_idx to the correspodning TC and read
> TFCS accordingly.
> 
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
