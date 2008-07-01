From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Fix e100 on systems that have cache
	incoherent DMA
Date: Tue, 1 Jul 2008 11:07:59 -0700
Message-ID: <20080701110759.4df83d71.akpm@linux-foundation.org>
References: <20071108181741.8648.61629.stgit@localhost.localdomain>
	<474DBDA6.50705@roinet.com> <474DBFCE.8010101@intel.com>
	<474DC0F3.8070604@garzik.org> <474DC68D.9020003@roinet.com>
	<485959DC.80902@users.sourceforge.net>
	<48595F16.5000905@roinet.com>
	<485A5349.6070601@users.sourceforge.net>
	<20080701012631.c3d1d262.akpm@linux-foundation.org>
	<4869FDBB.80501@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, miltonm@bga.com,
	Anders =?ISO-8859-1?Q?Grafstr=F6m?= <grfstrm@users.sourceforge.net>,
	David Acker <dacker@roinet.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <4869FDBB.80501@garzik.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, 01 Jul 2008 05:49:47 -0400 Jeff Garzik <jeff@garzik.org> wrote:

> Andrew Morton wrote:
> > On Thu, 19 Jun 2008 14:38:33 +0200 Anders Grafstr__m <grfstrm@users.sourceforge.net> wrote:
> > 
> >> David Acker wrote:
> >>> May I ask what actual board you are using and how the e100 is connected 
> >>> to it?  I plan to test with miniPCI based e100 cards.  Also, can you say 
> >>> more about it being broke?  Does it crash immediately, fail to move any 
> >>> data, move some data and stop, etc. ?
> >> It's a custom board based on the IXDP425 reference design.
> >> IXP420 with 82551ER integrated on the same board.
> >> Both RX and TX appears to stop shortly after the driver has been initialized.
> >> It never recovers after the "exec cuc_dump_reset failed" messages start to show.
> > 
> > So..  where are we with this?
> 
> It's in net-2.6, davem's 2.6.26-rc queue.
> 

ah, thanks.  Is it needed in 2.6.25.x?

-------------------------------------------------------------------------
Sponsored by: SourceForge.net Community Choice Awards: VOTE NOW!
Studies have shown that voting for your favorite open source project,
along with a healthy diet, reduces your potential for chronic lameness
and boredom. Vote Now at http://www.sourceforge.net/community/cca08
