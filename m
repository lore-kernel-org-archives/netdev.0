From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/3] ixgbe: Streamline MC filter setup for
 VFs
Date: Thu, 06 May 2010 00:32:15 -0700 (PDT)
Message-ID: <20100506.003215.57459704.davem@davemloft.net>
References: <20100506055703.8482.16515.stgit@localhost.localdomain>
	<20100506055728.8482.77386.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, gregory.v.rose@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57726
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753818Ab0EFHcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 03:32:08 -0400
In-Reply-To: <20100506055728.8482.77386.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 05 May 2010 22:57:30 -0700

> From: Greg Rose <gregory.v.rose@intel.com>
> 
> The driver was calling the set Rx mode function for every multicast
> filter set by the VF.  When starting many VMs where each might have
> multiple VLAN interfaces this would result in the function being
> called hundreds or even thousands of times.  This is unnecessary
> for the case of the imperfect filters used in the MTA and has been
> streamlined to be more efficient.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
