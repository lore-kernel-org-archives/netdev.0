From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH] ixgbe: Implement PCIe AER support
Date: Mon, 01 Dec 2008 23:25:27 -0800 (PST)
Message-ID: <20081201.232527.66213356.davem@davemloft.net>
References: <20081202004115.12058.64881.stgit@gitlost.lost>
	<20081201174754.2e5ef401@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, peter.p.waskiewicz.jr@intel.com,
	linux-pci@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20081201174754.2e5ef401@extreme>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 1 Dec 2008 17:47:54 -0800

> pci_enable_pcie_error_reporting should be checking for pci_read/pci_write
> config errors and does not.
> 
> Your driver should be checking for pci_enable_pcie_error_reporting failing.

Agreed.
