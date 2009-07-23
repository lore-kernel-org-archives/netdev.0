From: Robert Love <robert.w.love@intel.com>
Subject: Re: [Open-FCoE] [net-next-2.6 PATCH 5/5] fcoe: Use
 NETIF_F_FCOE_MTU flag to set up	max frame size (lport->mfs)
Date: Thu, 23 Jul 2009 11:27:28 -0700
Message-ID: <1248373648.23392.24.camel@fritz>
References: <20090722232759.26937.78765.stgit@localhost.localdomain>
	 <20090722232956.26937.24429.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
	gospo@redhat.com, devel@open-fcoe.org
To: davem@davemloft.net, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090722232956.26937.24429.stgit@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2009-07-22 at 16:29 -0700, Jeff Kirsher wrote:
> From: Yi Zou <yi.zou@intel.com>
> 
> Add a define of FCOE_MTU as 2158 bytes and use FCOE_MTU when the LLD is found
> to support NETIF_F_FCOE_MTU. The lport->mfs is then calculated out of the
> 2158 FCOE_MTU. Otherwise, we stick with the netdev->mtu, i.e., LAN MTU. Also,
> change the notification on NETDEV_CHANGEMTU event to bypass changing mfs when
> LAN MTU is changed if NETIF_F_FCOE_MTU is supported.
> 
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---

Hi Dave,

Please don't apply this patch to net-next. The other 4 patches in this
series should be fine without it. If this patch is applied to net-next
it means that most/all of the other fcoe features (that will go through
linux-scsi) become dependent on this patch.

I was hoping to push the other fcoe features as-is and then push this
patch through linux-scsi after the other 4 patches in this series had
been merged by you.

Thanks, //Rob


