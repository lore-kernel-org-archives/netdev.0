From: Alexander Gordeev <agordeev@redhat.com>
Subject: Re: [PATCH RFC 06/77] PCI/MSI: Factor out pci_get_msi_cap() interface
Date: Fri, 4 Oct 2013 07:13:24 +0200
Message-ID: <20131004051322.GA3577@dhcp-26-207.brq.redhat.com>
References: <cover.1380703262.git.agordeev@redhat.com>
 <9c282c4ab92731c719d161d2db6fc54ce33891d9.1380703262.git.agordeev@redhat.com>
 <1380837174.3419.21.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Bjorn Helgaas <bhelgaas@google.com>,
        Ralf Baechle <ralf@linux-mips.org>,
        Michael Ellerman <michael@ellerman.id.au>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Ingo Molnar <mingo@redhat.com>, Tejun Heo <tj@kernel.org>,
        Dan Williams <dan.j.williams@intel.com>,
        Andy King <acking@vmware.com>, Jon Mason <jon.mason@intel.com>,
        Matt Porter <mporter@kernel.crashing.org>,
        linux-pci@vger.kernel.org, linux-mips@linux-mips.org,
        linuxppc-dev@lists.ozlabs.org, linux390@de.ibm.com,
        linux-s390@vger.kernel.org, x86@kernel.org,
        linux-ide@vger.kernel.org, iss_storagedev@hp.com,
        linux-nvme@lists.infradead.org, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
        linux-dr
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <1380837174.3419.21.camel@bwh-desktop.uk.level5networks.com>
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

On Thu, Oct 03, 2013 at 10:52:54PM +0100, Ben Hutchings wrote:
> On Wed, 2013-10-02 at 12:48 +0200, Alexander Gordeev wrote:
> >  #ifndef CONFIG_PCI_MSI
> > +static inline int pci_get_msi_cap(struct pci_dev *dev)
> > +{
> > +	return -1;
> [...]
> 
> Shouldn't this also return -EINVAL?

Yep, all inliners here are better to return -EINVAL.
Will do unless someone speaks out against.

> Ben.

-- 
Regards,
Alexander Gordeev
agordeev@redhat.com
