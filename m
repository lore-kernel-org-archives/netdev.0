From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [NET-NEXT PATCH] ixgbe: Implement PCIe AER support
Date: Mon, 1 Dec 2008 17:47:54 -0800
Message-ID: <20081201174754.2e5ef401@extreme>
References: <20081202004115.12058.64881.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	linux-pci@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20081202004115.12058.64881.stgit@gitlost.lost>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 01 Dec 2008 16:41:15 -0800
Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:

> From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> 
> This patch implements the PCIe Advanced Error Reporting callbacks in
> ixgbe.  The 82598 hardware supports AER, so we enable it.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---

Once again: pcie-aer is not checking for mmconfig working!
If you turn it on, you may get screaming errors.

pci_enable_pcie_error_reporting should be checking for pci_read/pci_write
config errors and does not.

Your driver should be checking for pci_enable_pcie_error_reporting failing.
