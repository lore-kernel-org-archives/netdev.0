From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/7] ixgbe: Set the correct pool when
 VLANs are added in SR-IOV mode.
Date: Sat, 23 Jan 2010 01:14:15 -0800 (PST)
Message-ID: <20100123.011415.133422524.davem@davemloft.net>
References: <20100123084457.9865.51853.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, gregory.v.rose@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51041
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751082Ab0AWJOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 04:14:04 -0500
In-Reply-To: <20100123084457.9865.51853.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 23 Jan 2010 00:45:43 -0800

> From: Greg Rose <gregory.v.rose@intel.com>
> 
> When VFs are allocated (as indicated by adapter->num_vfs is non-zero) then
> the PF pool is no longer zero.  Instead it will be the same as the number
> of VFs allocated.  When setting the VLVF entry for the PF we need to use
> the correct pool otherwise the PF will get VLAN packets from the wire
> because the packet will pass VFTA filtering and the PF has the default
> pool, but it will not get VLAN packets from the VFs because it has
> not set the correct pool bit in the VLVF entry.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
