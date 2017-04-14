From: Bjorn Helgaas <helgaas@kernel.org>
Subject: Re: export pcie_flr and remove copies of it in drivers
Date: Fri, 14 Apr 2017 09:41:08 -0500
Message-ID: <20170414144108.GB29349@bhelgaas-glaptop.roam.corp.google.com>
References: <20170413145339.20186-1-hch@lst.de>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170413145339.20186-1-hch@lst.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 13, 2017 at 04:53:32PM +0200, Christoph Hellwig wrote:
> Hi all,
> 
> this exports the PCI layer pcie_flr helper, and removes various opencoded
> copies of it.

Looks good to me (except the comment on probe).  If you want to apply
the whole series via netdev or some non-PCI tree, here's my ack for
the drivers/pci parts, assuming the probe thing is resolved:

Acked-by: Bjorn Helgaas <bhelgaas@google.com>

Otherwise, I'd be glad to take the series given acks for the non-PCI
parts.  Just let me know.

Bjorn
