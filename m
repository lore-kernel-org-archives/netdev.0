From: Christoph Hellwig <hch@lst.de>
Subject: Re: export pcie_flr and remove copies of it in drivers
Date: Fri, 14 Apr 2017 17:57:09 +0200
Message-ID: <20170414155709.GB22412@lst.de>
References: <20170413145339.20186-1-hch@lst.de> <20170414144108.GB29349@bhelgaas-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@lst.de>,
        Bjorn Helgaas <bhelgaas@google.com>,
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
To: Bjorn Helgaas <helgaas@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170414144108.GB29349@bhelgaas-glaptop.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 14, 2017 at 09:41:08AM -0500, Bjorn Helgaas wrote:
> Looks good to me (except the comment on probe).  If you want to apply
> the whole series via netdev or some non-PCI tree, here's my ack for
> the drivers/pci parts, assuming the probe thing is resolved:
> 
> Acked-by: Bjorn Helgaas <bhelgaas@google.com>
> 
> Otherwise, I'd be glad to take the series given acks for the non-PCI
> parts.  Just let me know.

I guess the best would be if you take the first three patches (once
resent) for the PCI tree for 4.12, then we can do the other patches
in the next merge window.
