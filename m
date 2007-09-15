From: "Mike Snitzer" <snitzer@gmail.com>
Subject: Re: Distributed storage. Move away from char device ioctls.
Date: Fri, 14 Sep 2007 22:54:56 -0400
Message-ID: <170fa0d20709141954m4cff4650pa3b2bfd347e23f74@mail.gmail.com>
References: <20070914185429.GA9439@2ka.mipt.ru> <46EADC02.9070409@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <46EADC02.9070409@garzik.org>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/14/07, Jeff Garzik <jeff@garzik.org> wrote:
> Evgeniy Polyakov wrote:
> > Hi.
> >
> > I'm pleased to announce fourth release of the distributed storage
> > subsystem, which allows to form a storage on top of remote and local
> > nodes, which in turn can be exported to another storage as a node to
> > form tree-like storages.
> >
> > This release includes new configuration interface (kernel connector over
> > netlink socket) and number of fixes of various bugs found during move
> > to it (in error path).
> >
> > Further TODO list includes:
> > * implement optional saving of mirroring/linear information on the remote
> >       nodes (simple)
> > * new redundancy algorithm (complex)
> > * some thoughts about distributed filesystem tightly connected to DST
> >       (far-far planes so far)
> >
> > Homepage:
> > http://tservice.net.ru/~s0mbre/old/?section=projects&item=dst
> >
> > Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
>
> My thoughts.  But first a disclaimer:   Perhaps you will recall me as
> one of the people who really reads all your patches, and examines your
> code and proposals closely.  So, with that in mind...
>
> I question the value of distributed block services (DBS), whether its
> your version or the others out there.  DBS are not very useful, because
> it still relies on a useful filesystem sitting on top of the DBS.  It
> devolves into one of two cases:  (1) multi-path much like today's SCSI,
> with distributed filesystem arbitrarion to ensure coherency, or (2) the
> filesystem running on top of the DBS is on a single host, and thus, a
> single point of failure (SPOF).

This distributed storage is very much needed; even if it were to act
as a more capable/performant replacement for NBD (or MD+NBD) in the
near term.  Many high availability applications don't _need_ all the
additional complexity of a full distributed filesystem.  So given
that, its discouraging to see you trying to gently push Evgeniy away
from all the promising work he has published.

Evgeniy, please continue your current work.

Mike
