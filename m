From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/5] igb: Use only a single Tx queue in
 SR-IOV mode
Date: Thu, 01 Jul 2010 22:50:03 -0700 (PDT)
Message-ID: <20100701.225003.139551397.davem@davemloft.net>
References: <20100701233733.16171.4629.stgit@localhost.localdomain>
	<20100701233814.16171.78454.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	stable@kernel.org, gregory.v.rose@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49323
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755089Ab0GBFtt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 01:49:49 -0400
In-Reply-To: <20100701233814.16171.78454.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 01 Jul 2010 16:38:16 -0700

> From: Greg Rose <gregory.v.rose@intel.com>
> 
> The 82576 expects the second rx queue in any pool to receive L2 switch
> loop back packets sent from the second tx queue in another pool.  The
> 82576 VF driver does not enable the second rx queue so if the PF driver
> sends packets destined to a VF from its second tx queue then the VF
> driver will never see them.  In SR-IOV mode limit the number of tx queues
> used by the PF driver to one. This patch fixes a bug reported in which
> the PF cannot communciate with the VF and should be considered for 2.6.34
> stable.
> 
> CC: stable@kernel.org
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
