From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH net 0/4] net: add rx_unhandled stat counter
Date: Thu, 28 Jan 2016 01:10:13 -0500
Message-ID: <20160128061012.GC59058@redhat.com>
References: <1453489882-57948-1-git-send-email-jarod@redhat.com>
 <1453926098-40181-1-git-send-email-jarod@redhat.com>
 <1453928987.20722.29.camel@edumazet-glaptop2.roam.corp.google.com>
 <20160128060215.GB59058@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tom Herbert <tom@herbertland.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44398 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754843AbcA1GKO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jan 2016 01:10:14 -0500
Content-Disposition: inline
In-Reply-To: <20160128060215.GB59058@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 28, 2016 at 01:02:15AM -0500, Jarod Wilson wrote:
> On Wed, Jan 27, 2016 at 01:09:47PM -0800, Eric Dumazet wrote:
> > On Wed, 2016-01-27 at 15:21 -0500, Jarod Wilson wrote:
> > 
> > > diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> > > index 289c231..7973ab5 100644
> > > --- a/include/linux/netdevice.h
> > > +++ b/include/linux/netdevice.h
> > > @@ -180,6 +180,7 @@ struct net_device_stats {
> > >  	unsigned long	tx_window_errors;
> > >  	unsigned long	rx_compressed;
> > >  	unsigned long	tx_compressed;
> > > +	unsigned long	rx_unhandled;
> > >  };
> > >  
> > 
> > This structure is deprecated, please do not add new fields in it,
> > as it will increase netlink answers for no good reason.
> > 
> > rtnl_link_stats64 is what really matters these days.
> 
> I'll respin the set without that, along with s/unhandled/nohandler/, which
> I somehow got screwed up in my head and realized a split second after
> hitting send. Outside of that, does this approach look sane? Should I
> bother with touching /proc/net/dev output or not?

Also, please excuse the poor excuse for a cover-letter that had a
duplicate of patch 1 in it. I'll fix that the next pass too.

/me hangs head in shame...

-- 
Jarod Wilson
jarod@redhat.com
