From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 7/8] ixgbe: Implement FCoE Rx side large
 receive offload feature to 82599
Date: Sun, 17 May 2009 13:58:29 -0700 (PDT)
Message-ID: <20090517.135829.147129568.davem@davemloft.net>
References: <20090513230924.11416.68752.stgit@localhost.localdomain>
	<20090513231152.11416.40697.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	yi.zou@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090513231152.11416.40697.stgit@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 13 May 2009 16:11:53 -0700

> From: Yi Zou <yi.zou@intel.com>
> 
> This patch implements the FCoE Rx side offload feature in ixgbe_main.c
> to 82599 using the Rx offload infrastructure code added in the previous
> patch. The large receive offload by Direct Data Placement (DDP) for
> FCoE is achieved by implementing the ndo_fcoe_ddp_setup and ndo_fcoe_ddp_done
> in net_device_ops via netdev. It is up to the ULD, i.e., fcoe and libfc
> to query and setup large receive offload accordingly through the corresponding
> netdev upon creating fcoe instances.
> 
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
