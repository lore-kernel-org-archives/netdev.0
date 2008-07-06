From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH 08/18] igb: Introduce multiple TX
 queues with infrastructure
Date: Sat, 05 Jul 2008 21:14:00 -0700 (PDT)
Message-ID: <20080705.211400.95116379.davem@davemloft.net>
References: <20080627175921.22428.52767.stgit@localhost.localdomain>
	<20080627180044.22428.21729.stgit@localhost.localdomain>
	<486E1ADE.50706@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, linux-kernel@vger.kernel.org
To: jeff@garzik.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <486E1ADE.50706@garzik.org>
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

From: Jeff Garzik <jeff@garzik.org>
Date: Fri, 04 Jul 2008 08:43:10 -0400

> Jeff Kirsher wrote:
> > From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> > 
> > This code adds multiple Tx queue infrastructure much like we
> > previously did in ixgbe. The MSI-X vector mapping is the bulk of
> > the change.
> > 
> > IAM can now be safely enabled and we've verified that it does
> > work correctly. We can also eliminate the tx ring lock.
> > 
> > Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> > Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
> > Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> > ---
> > 
> >  drivers/net/igb/igb.h      |    6 +-
> >  drivers/net/igb/igb_main.c |  160 ++++++++++++++++++++++++++++++--------------
> >  2 files changed, 113 insertions(+), 53 deletions(-)
> 
> presumably this should wait for david to finish his multi-TX stuff?

Adding infrastructure now is a good thing.  I did something similar
for NIU, and the Broadcom folks have done similar for bnx2*.

That's why the NIU multiqueue TX patch in my series was only 10 lines
of changes, all the infrastructure and init was in the driver already :-)

-------------------------------------------------------------------------
Sponsored by: SourceForge.net Community Choice Awards: VOTE NOW!
Studies have shown that voting for your favorite open source project,
along with a healthy diet, reduces your potential for chronic lameness
and boredom. Vote Now at http://www.sourceforge.net/community/cca08
