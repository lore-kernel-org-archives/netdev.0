From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH v4 4/9] rdma/cm: Update port reservation to support AF_IB
Date: Wed, 13 Feb 2013 11:26:12 -0700
Message-ID: <20130213182612.GA11812@obsidianresearch.com>
References: <1358891797-14625-1-git-send-email-sean.hefty@intel.com>
 <1358891797-14625-5-git-send-email-sean.hefty@intel.com>
 <511B7474.3040201@mellanox.com>
 <1828884A29C6694DAF28B7E6B8A8237368B9A40F@ORSMSX101.amr.corp.intel.com>
 <20130213181048.GC1601@obsidianresearch.com>
 <1828884A29C6694DAF28B7E6B8A8237368B9A432@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1828884A29C6694DAF28B7E6B8A8237368B9A432-P5GAC/sN6hmkrb+BlOpmy7fspsVTdybXVpNB7YpNyf8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 13, 2013 at 06:19:51PM +0000, Hefty, Sean wrote:
> > Sean, I've lost track of all this over time, but just to check in,
> > with this new interface, would it be possible to obsolete ib_ucm? That
> > seems desirable to me, as it is so flawed..
> 
> I'd love to obsolete ib_ucm.  This interface should make it
> possible, though some additional implementation would be needed
> (e.g. for automatic path migration).

Okay - but there are some nice gaps in the API to cleanly place such
things in future?

A long time ago we discussed having different paths for CM GMP,
inbound data and outbound data (ie the full IB asymetric pathing
model), did that get included in the API as well?

> I have an immediate need to connect using native IB addresses.  So
> without this, I'll be forced to use ib_ucm or roll a new user space
> CM.

Using ucm is alot of trouble. Many sites don't have it setup properly,
don't have proper device node permissions and the issue with unique
IDs ends up being critical..

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
