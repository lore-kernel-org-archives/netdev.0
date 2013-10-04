From: Jon Mason <jon.mason@intel.com>
Subject: Re: [PATCH RFC 01/77] PCI/MSI: Fix return value when
 populate_msi_sysfs() failed
Date: Thu, 3 Oct 2013 17:59:13 -0700
Message-ID: <20131004005912.GB4787@jonmason-lab>
References: <cover.1380703262.git.agordeev@redhat.com>
 <3ff5236944aae69f2cd934b5b6da7c1c269df7c1.1380703262.git.agordeev@redhat.com>
 <20131003003905.GK6768@jonmason-lab>
 <1380836781.3419.17.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Gordeev <agordeev@redhat.com>,
	linux-kernel@vger.kernel.org, Bjorn Helgaas <bhelgaas@google.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Michael Ellerman <michael@ellerman.id.au>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Ingo Molnar <mingo@redhat.com>, Tejun Heo <tj@kernel.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Andy King <acking@vmware.com>,
	Matt Porter <mporter@kernel.crashing.org>,
	stable@vger.kernel.org, linux-pci@vger.kernel.org,
	linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org,
	linux390@de.ibm.com, linux-s390@vger.kernel.org, x86@kernel.org,
	linux-ide@vger.kernel.org, iss_storagedev@hp.com,
	linux-nvme@lists.infradead.org, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	linux-driver@qlogic.com,
	Solarflare linux maintainers <linux-net-drivers@solarf
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-ide-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1380836781.3419.17.camel@bwh-desktop.uk.level5networks.com>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 03, 2013 at 10:46:21PM +0100, Ben Hutchings wrote:
> On Wed, 2013-10-02 at 17:39 -0700, Jon Mason wrote:
> > On Wed, Oct 02, 2013 at 12:48:17PM +0200, Alexander Gordeev wrote:
> > > Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
> > 
> > Since you are changing the behavior of the msix_capability_init
> > function on populate_msi_sysfs error, a comment describing why in this
> > commit would be nice.
> [...]
> 
> This function was already treating that error as fatal, and freeing the
> MSIs.  The change in behaviour is that it now returns the error code in
> this case, rather than 0.  This is obviously correct and properly
> described by the one-line summary.

If someone dumb, like me, is looking at this commit and trying to
figure out what is happening, having ANY commit message is good.  "Fix
the return value" doesn't tell me anything.  Documenting what issue(s)
would've been seen had the error case been encountered and what will
now been seen would be very nice.

> 
> Ben.
> 
> -- 
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
> 
