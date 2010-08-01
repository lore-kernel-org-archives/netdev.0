From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 2/2] igb/ixgbe: add code to trigger function reset
 if reset_devices is set
Date: Sun, 01 Aug 2010 01:15:16 -0700 (PDT)
Message-ID: <20100801.011516.191407437.davem@davemloft.net>
References: <20100731005803.32625.6891.stgit@localhost.localdomain>
	<20100731005910.32625.89518.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbarnes@virtuousgeek.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org, alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20100731005910.32625.89518.stgit@localhost.localdomain>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 30 Jul 2010 17:59:12 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This change makes it so that both igb and ixgbe can trigger a full pcie
> function reset if the reset_devices kernel parameter is defined.  The main
> reason for adding this is that kdump can cause serious issues when the
> kdump kernel resets the IOMMU while DMA transactions are still occurring.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

I tend to disagree with the essence of this change.

Which is that we should add workaround after workaround for things
that aren't functioning properly in kdump and kexec.

They should have a pass that shuts devices down properly, so that this
kind of stuff doesn't need to happen in the kernel we then boot into.

What happens on non-PCIE systems then?  Do they just lose when this
happens?

No, you dun goof'd.  :-) Find another way to fix this please.

Thanks.
