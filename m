From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [NET-NEXT PATCH] ixgbe: Implement PCIe AER support
Date: Mon, 8 Dec 2008 23:13:31 -0800 (Pacific Standard Time)
Message-ID: <Pine.WNT.4.64.0812082307290.696@ppwaskie-MOBL2.amr.corp.intel.com>
References: <20081202004115.12058.64881.stgit@gitlost.lost>
 <20081201174754.2e5ef401@extreme> <20081201.232527.66213356.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "shemminger@vyatta.com" <shemminger@vyatta.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20081201.232527.66213356.davem@davemloft.net>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 1 Dec 2008, David Miller wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Mon, 1 Dec 2008 17:47:54 -0800
> 
> > pci_enable_pcie_error_reporting should be checking for pci_read/pci_write
> > config errors and does not.
> >
> > Your driver should be checking for pci_enable_pcie_error_reporting failing.
> 
> Agreed.

I've finally been able to get back to this.  I've looked at any other 
prior use of the PCIe AER routines, and the only driver using it to date 
is the QLogic QLA2xxx driver in SCSI-land.  I've also looked at the return 
codes, with and without Stephen's recent AER patch, and there's not much 
the driver can do.  If it's catching the errors, the best I can do is 
print an error message, then continue along.

I've put that patch together, and will have it sent along shortly.  If 
there's something additional I'm missing here, please let me know.

Cheers,
-PJ
