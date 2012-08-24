From: James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: [PATCH 0/8] csiostor: Chelsio FCoE offload driver submission
Date: Fri, 24 Aug 2012 22:58:55 +0100
Message-ID: <1345845535.3283.74.camel@dabdike>
References: <1345760873-12101-1-git-send-email-naresh@chelsio.com>
	 <CAP=VYLqtcULyoxPv0z89SEFvvFJiBUpG0UhWXzfm8KVMoGmYpg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Naresh Kumar Inna <naresh@chelsio.com>, linux-scsi@vger.kernel.org,
	dm@chelsio.com, netdev@vger.kernel.org, chethan@chelsio.com
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <CAP=VYLqtcULyoxPv0z89SEFvvFJiBUpG0UhWXzfm8KVMoGmYpg@mail.gmail.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-08-24 at 17:45 -0400, Paul Gortmaker wrote:
> On Thu, Aug 23, 2012 at 6:27 PM, Naresh Kumar Inna <naresh@chelsio.com> wrote:
> > This is the initial submission of the Chelsio FCoE offload driver (csiostor)
> > to the upstream kernel. This driver currently supports FCoE offload
> > functionality over Chelsio T4-based 10Gb Converged Network Adapters.
> >
> > The following patches contain the driver sources for csiostor driver and
> > updates to firmware/hardware header files shared between csiostor and
> > cxgb4 (Chelsio T4-based NIC driver). The csiostor driver is dependent on these
> > header updates. These patches have been generated against scsi 'misc' branch.
> >
> > csiostor is a low level SCSI driver that interfaces with PCI, SCSI midlayer and
> > FC transport subsystems. This driver claims the FCoE PCIe function on the
> > Chelsio Converged Network Adapter. It relies on firmware events for slow path
> > operations like discovery, thereby offloading session management. The driver
> > programs firmware via Work Request interfaces for fast path I/O offload
> > features.
> >
> > Here is the brief description of patches:
> > [PATCH 1/8]: Hardware interface, Makefile and Kconfig changes.
> > [PATCH 2/8]: Driver initialization and Work Request services.
> > [PATCH 3/8]: FC transport interfaces and mailbox services.
> > [PATCH 4/8]: Local and remote port state tracking functionality.
> > [PATCH 5/8]: Interrupt handling and fast path I/O functionality.
> > [PATCH 6/8]: Header files part 1.
> > [PATCH 7/8]: Header files part 2.
> 
> Based on the above two, I'm guessing nothing will build and work
> on any of steps one through six?  Yet you expose the Kconfig
> and Makefile linkage into the tree in patch #1?   So your patches
> as presented are non bisectable.
> 
> You need to rethink your breakup in the presentation.  Factoring
> things just by files alone is not the right approach.  You need to
> ask yourself whether each commit is a stand-alone entity that does
> something independently on its own -- since they generally should.

Actually, this is fine for a new driver ... everything just gets put in
as a single commit.  There's really no point adding a driver in pieces
if it's not functional until the last patch, so in this case only, the
breakup is to help the review.

James


