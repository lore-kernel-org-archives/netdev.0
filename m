From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 3/3] ixgbe: fix traffic hangs on Tx with
 ioatdma loaded
Date: Fri, 06 Nov 2009 20:34:11 -0800 (PST)
Message-ID: <20091106.203411.259251330.davem@davemloft.net>
References: <20091106225526.28063.83720.stgit@localhost.localdomain>
	<20091106225620.28063.96209.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	donald.c.skidmore@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46684
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760211AbZKGEdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 23:33:46 -0500
In-Reply-To: <20091106225620.28063.96209.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 06 Nov 2009 14:56:20 -0800

> From: Don Skidmore <donald.c.skidmore@intel.com>
> 
> When ioatdma was loaded we we were unable to transmit traffic.  We weren't
> using the correct registers in ixgbe_update_tx_dca for 82599 systems.
> Likewise in ixgbe_configure_tx() we weren't disabling the arbiter before
> modifying MTQC.
> 
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
