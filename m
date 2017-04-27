From: Bjorn Helgaas <helgaas@kernel.org>
Subject: Re: [PATCH 5/7] IB/hfi1: use pcie_flr instead of duplicating it
Date: Thu, 27 Apr 2017 11:49:46 -0500
Message-ID: <20170427164946.GA8309@bhelgaas-glaptop.roam.corp.google.com>
References: <20170414191131.14286-1-hch@lst.de>
 <20170414191131.14286-6-hch@lst.de>
 <A33E225544E47D4DB5713032774B132783960382@irsmsx105.ger.corp.intel.com>
 <20170424143507.GA28812@lst.de>
 <20170425193955.GC29024@bhelgaas-glaptop.roam.corp.google.com>
 <20170427064758.GA20614@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Byczkowski, Jakub" <jakub.byczkowski@intel.com>,
        Bjorn Helgaas <bhelgaas@google.com>,
        "Cabiddu, Giovanni" <giovanni.cabiddu@intel.com>,
        "Benedetto, Salvatore" <salvatore.benedetto@intel.com>,
        "Marciniszyn, Mike" <mike.marciniszyn@intel.com>,
        "Dalessandro, Dennis" <dennis.dalessandro@intel.com>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
        qat-linux <qat-linux@intel.com>,
        "linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "net
To: Christoph Hellwig <hch@lst.de>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170427064758.GA20614@lst.de>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 27, 2017 at 08:47:58AM +0200, Christoph Hellwig wrote:
> On Tue, Apr 25, 2017 at 02:39:55PM -0500, Bjorn Helgaas wrote:
> > This still leaves these:
> > 
> >   [PATCH 4/7] ixgbe: use pcie_flr instead of duplicating it
> >   [PATCH 6/7] crypto: qat: use pcie_flr instead of duplicating it
> >   [PATCH 7/7] liquidio: use pcie_flr instead of duplicating it
> > 
> > I haven't seen any response to 4 and 6.  Felix reported an unused
> > variable in 7.  Let me know if you'd like me to do anything with
> > these.
> 
> Now that Jeff ACKed 4 it might be worth to add it to the pci tree last
> minute.  I'll resend liquidio and qat to the respective maintainers for
> the next merge window.

I applied 4 with Jeff's ack to pci/virtualization for v4.12, thanks!
