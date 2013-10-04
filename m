From: Alexander Gordeev <agordeev@redhat.com>
Subject: Re: [PATCH RFC 00/77] Re-design MSI/MSI-X interrupts enablement
 pattern
Date: Fri, 4 Oct 2013 11:21:09 +0200
Message-ID: <20131004092108.GB4536@dhcp-26-207.brq.redhat.com>
References: <cover.1380703262.git.agordeev@redhat.com>
 <1380840585.3419.50.camel@bwh-desktop.uk.level5networks.com>
 <20131004082920.GA4536@dhcp-26-207.brq.redhat.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7371@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
        linux-mips@linux-mips.org, "VMware, Inc." <pv-drivers@vmware.com>,
        linux-nvme@lists.infradead.org, linux-ide@vger.kernel.org,
        linux-s390@vger.kernel.org, Andy King <acking@vmware.com>,
        linux-scsi@vger.kernel.org, linux-rdma@vger.kernel.org,
        x86@kernel.org, Ingo Molnar <mingo@redhat.com>,
        linux-pci@vger.kernel.org, iss_storagedev@hp.com,
        linux-driver@qlogic.com, Tejun Heo <tj@kernel.org>,
        Bjorn Helgaas <bhelgaas@google.com>,
        Dan Williams <dan.j.williams@intel.com>,
        Jon Mason <jon.mason@intel.com>,
        Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Ralf Baechle <ralf@linux-mips.org>,
        e1000-devel@lists.sourceforge.net,
        Martin Schwidefsky <schwidefsky@de.ibm.co
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7371@saturn3.aculab.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

On Fri, Oct 04, 2013 at 09:31:49AM +0100, David Laight wrote:
> > Mmmm.. I am not sure I am getting it. Could you please rephrase?
> 
> One possibility is for drivers than can use a lot of interrupts to
> request a minimum number initially and then request the additional
> ones much later on.
> That would make it less likely that none will be available for
> devices/drivers that need them but are initialised later.

It sounds as a whole new topic for me. Isn't it?

Anyway, what prevents the above from being done with pci_enable_msix(nvec1) -
pci_disable_msix() - pci_enable_msix(nvec2) where nvec1 < nvec2?

> 	David

-- 
Regards,
Alexander Gordeev
agordeev@redhat.com
