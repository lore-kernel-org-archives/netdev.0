From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 01/12] vlan: adds fcoe offload related
 net_device_ops and updates fcoe_ddp_xid field
Date: Fri, 14 Aug 2009 16:12:36 -0700 (PDT)
Message-ID: <20090814.161236.86686048.davem@davemloft.net>
References: <20090814223857.1640.26881.stgit@localhost.localdomain>
	<20090814224106.1640.6910.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	gospo@redhat.com, vasu.dev@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090814224106.1640.6910.stgit@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 14 Aug 2009 15:41:07 -0700

> From: Vasu Dev <vasu.dev@intel.com>
> 
> Adds fcoe offload related net_device_ops functions vlan_dev_fcoe_ddp_setup
> and vlan_dev_fcoe_ddp_done, their implementation simply calls real eth device
> net_device_ops for FCoE DDP setup and done operations.
> 
> Updates VLAN netdev field value for fcoe_ddp_xid from real eth device netdev.
> 
> Above changes are required for fcoe DDP offload working on a VLAN interface.
> 
> Signed-off-by: Vasu Dev <vasu.dev@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
