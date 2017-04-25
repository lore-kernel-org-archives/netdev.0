From: Bjorn Helgaas <helgaas-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 5/7] IB/hfi1: use pcie_flr instead of duplicating it
Date: Tue, 25 Apr 2017 14:39:55 -0500
Message-ID: <20170425193955.GC29024@bhelgaas-glaptop.roam.corp.google.com>
References: <20170414191131.14286-1-hch@lst.de>
 <20170414191131.14286-6-hch@lst.de>
 <A33E225544E47D4DB5713032774B132783960382@irsmsx105.ger.corp.intel.com>
 <20170424143507.GA28812@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Byczkowski, Jakub" <jakub.byczkowski-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Bjorn Helgaas <bhelgaas-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        "Cabiddu, Giovanni" <giovanni.cabiddu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "Benedetto, Salvatore" <salvatore.benedetto-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "Marciniszyn, Mike" <mike.marciniszyn-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "Dalessandro, Dennis" <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Derek Chickles <derek.chickles-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>,
        Satanand Burla <satananda.burla-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>,
        Felix Manlunas <felix.manlunas-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>,
        Raghu Vatsavayi <raghu.vatsavayi-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        qat-linux <qat-linux-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "net
To: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170424143507.GA28812-jcswGhMUV9g@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 24, 2017 at 04:35:07PM +0200, Christoph Hellwig wrote:
> On Mon, Apr 24, 2017 at 02:16:31PM +0000, Byczkowski, Jakub wrote:
> > Tested-by: Jakub Byczkowski <jakub.byczkowski-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> 
> Are you (and Doug) ok with queueing this up in the PCI tree?

Applied this with Jakub's tested-by and Doug's ack to pci/virtualization
for v4.12.

This still leaves these:

  [PATCH 4/7] ixgbe: use pcie_flr instead of duplicating it
  [PATCH 6/7] crypto: qat: use pcie_flr instead of duplicating it
  [PATCH 7/7] liquidio: use pcie_flr instead of duplicating it

I haven't seen any response to 4 and 6.  Felix reported an unused
variable in 7.  Let me know if you'd like me to do anything with
these.

Bjorn
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
