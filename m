From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: RE: pcie_get_minimum_link returns 0 width
Date: Mon, 26 Aug 2013 23:36:50 +0000
Message-ID: <979A8436335E3744ADCD3A9F2A2B68A52AD13D0C@SJEXCHMB10.corp.ad.broadcom.com>
References: <20130825100157.GA16500@lb-tlvb-yuvalmin.il.broadcom.com>
 <979A8436335E3744ADCD3A9F2A2B68A52AD136BE@SJEXCHMB10.corp.ad.broadcom.com>
 <CAErSpo4NmL0RWcBompuweHNYmhNmLXU_21_gvaqfDEzi+HBp5g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "jacob.e.keller@intel.com" <jacob.e.keller@intel.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Bjorn Helgaas" <bhelgaas@google.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <CAErSpo4NmL0RWcBompuweHNYmhNmLXU_21_gvaqfDEzi+HBp5g@mail.gmail.com>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Hi,
> >
> > I tried adding support for the newly added 'pcie_get_minimum_link' into
> the
> > bnx2x driver, but found out the some of my devices started showing width
> x0.
> >
> > By adding debug prints, I've found out there were devices up the chain that
> > Showed 0 when their PCI_EXP_LNKSTA was read by said function.
> > However, when I tried looking via lspci the output claimed the width was
> x4.
> 
> I don't see a 'pcie_get_minimum_link()' function in my current tree
> (git://git.kernel.org/pub/scm/linux/kernel/git/helgaas/pci.git "next"
> branch).  Maybe seeing your patch (with the debug prints) would give
> me a hook for somewhere to start looking.

You've acked the patch and it was applied in net-next; Obviously it has yet
to migrate to your tree. 

> 
> Can you figure out why lspci shows the correct value and this kernel
> interface does not?  The current lspci source is in
> git://git.kernel.org/pub/scm/utils/pciutils/pciutils.git and the
> relevant code is probably in cap_express_link() here:
> http://git.kernel.org/cgit/utils/pciutils/pciutils.git/tree/ls-caps.c#n750

Traced the read as going via the pci-sysfs. Where should I look for the bus's
read ops?

Thanks,
Yuval
