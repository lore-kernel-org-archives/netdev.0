From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Thu, 24 Dec 2009 12:01:59 +0200
Message-ID: <20091224100159.GA26152@redhat.com>
References: <4B1D4F29.8020309@gmail.com> <20091218215107.GA14946@elte.hu> <4B2F9582.5000002@gmail.com> <20091222075742.GB26467@elte.hu> <4B3103B4.4070708@gmail.com> <f73f7ab80912222215i39ba865dv95764f95fd57bd96@mail.gmail.com> <4B3254B4.2080602@gmail.com> <20091223192808.GA30700@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gregory Haskins <gregory.haskins@gmail.com>,
	Kyle Moffett <kyle@moffetthome.net>,
	Ingo Molnar <mingo@elte.hu>, Avi Kivity <avi@redhat.com>,
	kvm@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: "Ira W. Snyder" <iws@ovro.caltech.edu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756667AbZLXKHA@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091223192808.GA30700@ovro.caltech.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 23, 2009 at 11:28:08AM -0800, Ira W. Snyder wrote:
> On Wed, Dec 23, 2009 at 12:34:44PM -0500, Gregory Haskins wrote:
> > On 12/23/09 1:15 AM, Kyle Moffett wrote:
> > > On Tue, Dec 22, 2009 at 12:36, Gregory Haskins
> > > <gregory.haskins@gmail.com> wrote:
> > >> On 12/22/09 2:57 AM, Ingo Molnar wrote:
> > >>> * Gregory Haskins <gregory.haskins@gmail.com> wrote:
> > >>>> Actually, these patches have nothing to do with the KVM folks. [...]
> > >>>
> > >>> That claim is curious to me - the AlacrityVM host
> > >>
> > >> It's quite simple, really.  These drivers support accessing vbus, and
> > >> vbus is hypervisor agnostic.  In fact, vbus isn't necessarily even
> > >> hypervisor related.  It may be used anywhere where a Linux kernel is the
> > >> "io backend", which includes hypervisors like AlacrityVM, but also
> > >> userspace apps, and interconnected physical systems as well.

So focus on interconnecting physical systems I think would be one way
for vbus to stop conflicting with KVM. If drivers for such systems
appear I expect that relevant (hypervisor-agnostic) vbus bits would be
very uncontroversial.

This would not be the first technology to make the jump from attempting
to be a PCI replacement to being an interconnect btw, I think infiniband
did this as well.

-- 
MST
