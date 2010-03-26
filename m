From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 3/3] ixgbe: Change where clear_to_send_flag is
 reset to zero.
Date: Fri, 26 Mar 2010 11:58:03 -0700 (PDT)
Message-ID: <20100326.115803.264745618.davem@davemloft.net>
References: <20100324193515.6078.27035.stgit@localhost.localdomain>
	<20100324193626.6078.32074.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, gregory.v.rose@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50461
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753224Ab0CZS5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 14:57:39 -0400
In-Reply-To: <20100324193626.6078.32074.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 24 Mar 2010 12:36:27 -0700

> From: Greg Rose <gregory.v.rose@intel.com>
> 
> The clear_to_send flag is being cleared before the call to ping all
> the VFs.  It should be called after pinging all the VFs.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
