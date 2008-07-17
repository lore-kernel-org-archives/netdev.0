From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCHv2] ipvs: Cleanup sync daemon code
Date: Thu, 17 Jul 2008 12:48:50 +1000
Message-ID: <20080717024848.GC23699@verge.net.au>
References: <1214760766-1526-1-git-send-email-sven.wegener@stealer.net> <20080630045153.GA25021@verge.net.au> <alpine.LNX.1.10.0807170004580.17284@titan.stealer.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wensong@linux-vs.org, ja@ssi.bg, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Sven Wegener <sven.wegener@stealer.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:38505 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752767AbYGQCsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 22:48:52 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LNX.1.10.0807170004580.17284@titan.stealer.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 17, 2008 at 01:33:44AM +0200, Sven Wegener wrote:
> On Mon, 30 Jun 2008, Simon Horman wrote:
> 
> > On Sun, Jun 29, 2008 at 07:32:41PM +0200, Sven Wegener wrote:
> > > It's been a while since my last post of this patch series, but here we go gain.
> > > 
> > > Changes since last post:
> > > - Dropped the master daemon sleep change for now, that needs some more work.
> > > - Splitted up the patch into a couple of logical chunks.
> > > 
> > > The patches are
> > > 
> > > Sven Wegener (5):
> > >       ipvs: Initialize mcast addr at compile time
> > >       ipvs: Use ERR_PTR for returning errors from make_receive_sock() and make_send_sock()
> > >       ipvs: Use kthread_run() instead of doing a double-fork via kernel_thread()
> > >       ipvs: Put backup thread on mcast socket wait queue
> > >       ipvs: Use schedule_timeout_interruptible() instead of msleep_interruptible()
> > > 
> > > The overall difstat looks like
> > > 
> > >  ip_vs_sync.c |  431 +++++++++++++++++++++++------------------------------------
> > >   1 file changed, 172 insertions(+), 259 deletions(-)
> > > 
> > > The patches are based on v2.6.26-rc8. If someone wants to pull them, that can
> > > be done from
> > > 
> > > git://git.stealer.net/linux-2.6.git stealer/ipvs/sync-daemon-cleanup
> > 
> > These patches look good to me.
> 
> So, who is going to take these patches? I expect them to go through 
> davem's net-next tree, so I've rebased them onto his tree and appended 
> your acked-by. The hton -> __constant_hton change is included.
> 
> The changes 0b57664..375c6bb are available at
> 
> git://git.stealer.net/linux-2.6.git stealer/ipvs/sync-daemon-cleanup-for-next

Thanks, verified, they look good to me :-)

Dave, is there anything I can do to make merging these patches easier for you?

-- 
Horms

