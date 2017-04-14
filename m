From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 1/7] PCI: export pcie_flr
Date: Fri, 14 Apr 2017 17:56:27 +0200
Message-ID: <20170414155627.GA22412@lst.de>
References: <20170413145339.20186-1-hch@lst.de> <20170413145339.20186-2-hch@lst.de> <20170414143416.GA29349@bhelgaas-glaptop.roam.corp.google.com>
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
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Alex Williamson <alex.williamson@redhat.com>
To: Bjorn Helgaas <helgaas@kernel.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170414143416.GA29349@bhelgaas-glaptop.roam.corp.google.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> s/pcie_has_flr/pcie_has_flr()/

Ok.

> This performs an FLR (if supported) always, regardless of "probe".
> I think it should look something like this instead:
> 
>   if (pcie_has_flr(dev)) {
>     if (!probe)
>       pcie_flr(dev);
>     rc = 0;
>     goto done;
>   }

Indeed!
