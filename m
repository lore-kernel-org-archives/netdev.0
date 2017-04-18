From: Bjorn Helgaas <helgaas@kernel.org>
Subject: Re: export pcie_flr and remove copies of it in drivers V2
Date: Tue, 18 Apr 2017 13:36:12 -0500
Message-ID: <20170418183612.GC25295@bhelgaas-glaptop.roam.corp.google.com>
References: <20170414191131.14286-1-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bjorn Helgaas <bhelgaas@google.com>,
        Giovanni Cabiddu <giovanni.cabiddu@intel.com>,
        Salvatore Benedetto <salvatore.benedetto@intel.com>,
        Mike Marciniszyn <mike.marciniszyn@intel.com>,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        linux-pci@vger.kernel.org, qat-linux@intel.com,
        linux-crypto@vger.kernel.org, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170414191131.14286-1-hch@lst.de>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 14, 2017 at 09:11:24PM +0200, Christoph Hellwig wrote:
> Hi all,
> 
> this exports the PCI layer pcie_flr helper, and removes various opencoded
> copies of it.
> 
> Changes since V1:
>  - rebase on top of the pci/virtualization branch
>  - fixed the probe case in __pci_dev_reset
>  - added ACKs from Bjorn

Applied the first three patches:
 
  bc13871ef35a PCI: Export pcie_flr()
  e641c375d414 PCI: Call pcie_flr() from reset_intel_82599_sfp_virtfn()
  40e0901ea4bf PCI: Call pcie_flr() from reset_chelsio_generic_dev()

to pci/virtualization for v4.12, thanks!
