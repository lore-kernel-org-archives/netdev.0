From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 3/7] ixgbe: Allow the VF driver to be
 loaded before the PF driver
Date: Sat, 23 Jan 2010 01:14:27 -0800 (PST)
Message-ID: <20100123.011427.195715596.davem@davemloft.net>
References: <20100123084457.9865.51853.stgit@localhost.localdomain>
	<20100123084620.9865.56449.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, gregory.v.rose@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51051
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751695Ab0AWJOQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 04:14:16 -0500
In-Reply-To: <20100123084620.9865.56449.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 23 Jan 2010 00:46:22 -0800

> From: Greg Rose <gregory.v.rose@intel.com>
> 
> The PF Reset Done bit should not be set in the extended control register
> until the PF has actually completed the bring up process.  It is a mis-
> interpretation of the purpose of this bit to assume it should be set
> when the physical reset of the device is done.  Instead it should be used
> to indicate to the VFs when the PF is ready to provide them with required
> services.  This is not until after the PF is finished coming up and ready
> to process mailbox events.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
