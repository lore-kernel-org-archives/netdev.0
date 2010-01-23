From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 4/7] ixgbe: Improve reset coordination
 between the PF and the VF
Date: Sat, 23 Jan 2010 01:14:33 -0800 (PST)
Message-ID: <20100123.011433.145132116.davem@davemloft.net>
References: <20100123084457.9865.51853.stgit@localhost.localdomain>
	<20100123084639.9865.47156.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, gregory.v.rose@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51055
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751943Ab0AWJOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 04:14:21 -0500
In-Reply-To: <20100123084639.9865.47156.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 23 Jan 2010 00:46:40 -0800

> From: Greg Rose <gregory.v.rose@intel.com>
> 
> Inadequate coordination between the PF driver and the VF driver results
> in tx hangs in the VF driver when you perform certain actions that will
> lead to a re-init of the PF.  Add feature to notify active VFs when the PF
> is about to re-initialize so that the VFs can take appropriate action.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
