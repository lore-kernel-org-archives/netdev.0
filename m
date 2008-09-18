From: "Benjamin Li" <benli@broadcom.com>
Subject: [UPDATED][NET-NEXT PATCH 0/4] Minor bnx2 patches
Date: Thu, 18 Sep 2008 09:57:09 -0700
Message-ID: <1221757033-4874-1-git-send-email-benli@broadcom.com>
References: <20080918063933.GA8027@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: benli@broadcom.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3318 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756514AbYIRQ5d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2008 12:57:33 -0400
In-Reply-To: <20080918063933.GA8027@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the comments Simon.  I have integrated the changes that you have suggested.  I have reposted the entire patch set in numbered form so that it could be merged in easier.

Thanks again.

-Ben

> @@ -7514,7 +7514,6 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
> >
> >       bp->stats_ticks = USEC_PER_SEC & BNX2_HC_STATS_TICKS_HC_STAT_TICKS;
> >
> > -     bp->timer_interval =  HZ;
> >       bp->current_interval =  HZ;
> 
> Would it make sense to set current_interval to BNX2_TIMER_INTERVAL?

Changed.

> >
> > diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
> > index cb47c98..e534c1d 100644
> > --- a/drivers/net/bnx2.h
> > +++ b/drivers/net/bnx2.h
> > @@ -6701,7 +6701,7 @@ struct bnx2 {
> >
> >       /* End of fields used in the performance code paths. */
> >
> > -     int                     timer_interval;
> > +#define BNX2_TIMER_INTERVAL                  HZ
> 
> Perhaps its just me, but would it be nicer to define BNX2_TIMER_INTERVAL
> somewhere other than in the middle of this structure?
> 
Moved outside of the bnx2 structure.

--------------------

Benjamin Li (4):
  bnx2: In bnx2_set_mac_link() return void rather then int
  bnx2: Update MODULE_DESCRIPTION to include the 5716
  bnx2: Remove name field from bnx2 structure
  bnx2: Remove timer_interval field from the bnx2 structure

 drivers/net/bnx2.c |   22 +++++++++-------------
 drivers/net/bnx2.h |    5 ++---
 2 files changed, 11 insertions(+), 16 deletions(-)


