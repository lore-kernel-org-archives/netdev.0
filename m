From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [NET-NEXT PATCH] ixgbe: Implement PCIe AER support
Date: Tue, 2 Dec 2008 00:19:20 -0800 (Pacific Standard Time)
Message-ID: <Pine.WNT.4.64.0812020015030.4420@ppwaskie-MOBL2.amr.corp.intel.com>
References: <20081202004115.12058.64881.stgit@gitlost.lost>
 <20081201174754.2e5ef401@extreme>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20081201174754.2e5ef401@extreme>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 1 Dec 2008, Stephen Hemminger wrote:

> On Mon, 01 Dec 2008 16:41:15 -0800
> Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
> 
> > From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> > 
> > This patch implements the PCIe Advanced Error Reporting callbacks in
> > ixgbe.  The 82598 hardware supports AER, so we enable it.
> > 
> > Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > ---
> 
> Once again: pcie-aer is not checking for mmconfig working!
> If you turn it on, you may get screaming errors.
> 
> pci_enable_pcie_error_reporting should be checking for pci_read/pci_write
> config errors and does not.
> 
> Your driver should be checking for pci_enable_pcie_error_reporting failing.

I'll respin and have a new patch sent for this.  I just finally saw the 
igb thread, so my apologies for missing this earlier.

Cheers,
-PJ
