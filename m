From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [Patch 1/5] Network Drop Monitor: Add netlink protocol
	identifer
Date: Tue, 3 Mar 2009 14:00:54 -0500
Message-ID: <20090303190054.GI1480@hmsreliant.think-freely.org>
References: <20090303170014.GB1480@hmsreliant.think-freely.org> <20090303182006.GB29236@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48818 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753906AbZCCTBD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 14:01:03 -0500
Content-Disposition: inline
In-Reply-To: <20090303182006.GB29236@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 03, 2009 at 09:20:06PM +0300, Evgeniy Polyakov wrote:
> Hi Neil.
> 
> On Tue, Mar 03, 2009 at 12:00:14PM -0500, Neil Horman (nhorman@tuxdriver.com) wrote:
> > 
> > Network Drop Monitor: Add Netlink protocol identifier
> >     
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> > 
> > 
> >  netlink.h |    1 +
> >  1 file changed, 1 insertion(+)
> > 
> > diff --git a/include/linux/netlink.h b/include/linux/netlink.h
> > index 1e6bf99..d4ac636 100644
> > --- a/include/linux/netlink.h
> > +++ b/include/linux/netlink.h
> > @@ -24,6 +24,7 @@
> >  /* leave room for NETLINK_DM (DM Events) */
> >  #define NETLINK_SCSITRANSPORT	18	/* SCSI Transports */
> >  #define NETLINK_ECRYPTFS	19
> > +#define NETLINK_DRPMON		20	/* Netork packet drop alerts */
> >  
> >  #define MAX_LINKS 32		
> >  
> 
> Why do you want to use own family instead of using existing netlink
> helpers like connector or genetlink?
> 
Because this is its own protocol.  I could have used NETLINK_GENERIC I suppose,
but this is a feature that, if used is going to be commonly built into the
kernel, I see no need to add an additional step of making userspace search for a
protocol registered to NETLINK_GENERIC when we dont need to.  In other words,
why not define my own protocol?
Neil

> -- 
> 	Evgeniy Polyakov
> 
