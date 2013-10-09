From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH RFC 00/77] Re-design MSI/MSI-X interrupts enablement
 pattern
Date: Wed, 9 Oct 2013 11:57:52 -0400
Message-ID: <20131009155752.GE22495@htj.dyndns.org>
References: <cover.1380703262.git.agordeev@redhat.com>
 <20131007182117.GC27396@htj.dyndns.org>
 <20131008090716.GA10561@dhcp-26-207.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Bjorn Helgaas <bhelgaas@google.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Michael Ellerman <michael@ellerman.id.au>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Ingo Molnar <mingo@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Andy King <acking@vmware.com>, Jon Mason <jon.mason@intel.com>,
	Matt Porter <mporter@kernel.crashing.org>,
	linux-pci@vger.kernel.org, linux-mips@linux-mips.org,
	linuxppc-dev@lists.ozlabs.org, linux390@de.ibm.com,
	linux-s390@vger.kernel.org, x86@kernel.org,
	linux-ide@vger.kernel.org, iss_storagedev@hp.com,
	linux-nvme@lists.infradead.org, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	linux-driver@qlogic.com,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	"VMware, Inc." <pv-drivers@vmware.com>, linux-sc
To: Alexander Gordeev <agordeev@redhat.com>
Return-path: <linux-ide-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131008090716.GA10561@dhcp-26-207.brq.redhat.com>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Tue, Oct 08, 2013 at 11:07:16AM +0200, Alexander Gordeev wrote:
> Multipe MSIs is just a handful of drivers, really. MSI-X impact still

Yes, so it's pretty nice to try out things there before going full-on.

> will be huge. But if we opt a different name for the new pci_enable_msix()
> then we could first update pci/msi, then drivers (in few stages possibly)
> and finally remove the old implementation.

Yes, that probably should be the steps to follow eventually.  My point
was that you don't have to submit patches for all 7x conversions for
an RFC round.  Scanning them and seeing what would be necessary
definitely is a good idea but just giving summary of the full
conversion with several examples should be good enough before settling
on the way forward, which should be easier for all involved.

Thanks a lot for your effort!

-- 
tejun
