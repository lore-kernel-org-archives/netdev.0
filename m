From: "David Laight" <David.Laight@ACULAB.COM>
Subject: Re: [PATCH RFC 00/77] Re-design MSI/MSI-X interrupts
	enablement pattern
Date: Fri, 4 Oct 2013 09:31:49 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7371@saturn3.aculab.com>
References: <cover.1380703262.git.agordeev@redhat.com>
	<1380840585.3419.50.camel@bwh-desktop.uk.level5networks.com>
	<20131004082920.GA4536@dhcp-26-207.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, "VMware, Inc." <pv-drivers@vmware.com>,
	linux-pci@vger.kernel.org, linux-nvme@lists.infradead.org,
	linux-ide@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>,
	linux-s390@vger.kernel.org, Andy King <acking@vmware.com>,
	linux-scsi@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	x86@kernel.org, Ingo Molnar <mingo@redhat.com>,
	iss_storagedev@hp.com, Tejun Heo <tj@kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Dan Williams <dan.j.williams@intel.com>, Jon Mason <jon.mason@intel.com>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ralf Baechle <ralf@linux-mips.org>, linux-rdma@vger.kernel.org,
	linux-driver@qlogic.com, linux390@de.ibm.com, linuxppc-dev@lists.ozlabs.org
To: "Alexander Gordeev" <agordeev@redhat.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-class: urn:content-classes:message
In-Reply-To: <20131004082920.GA4536@dhcp-26-207.brq.redhat.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

> > It seems to me that a more useful interface would take a minimum and
> > maximum number of vectors from the driver.  This wouldn't allow the
> > driver to specify that it could only accept, say, any even number within
> > a certain range, but you could still leave the current functions
> > available for any driver that needs that.
> 
> Mmmm.. I am not sure I am getting it. Could you please rephrase?

One possibility is for drivers than can use a lot of interrupts to
request a minimum number initially and then request the additional
ones much later on.
That would make it less likely that none will be available for
devices/drivers that need them but are initialised later.

	David




------------------------------------------------------------------------------
October Webinars: Code for Performance
Free Intel webinars can help you accelerate application performance.
Explore tips for MPI, OpenMP, advanced profiling, and more. Get the most from 
the latest Intel processors and coprocessors. See abstracts and register >
http://pubads.g.doubleclick.net/gampad/clk?id=60134791&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
