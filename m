From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: ipw2200: Driver lockup
Date: Wed, 19 Jul 2006 22:58:10 -0400
Message-ID: <20060720025810.GA5901@tuxdriver.com>
References: <20060719142833.GA21345@linux-mips.org> <1153356597.2542.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralf Baechle <ralf@linux-mips.org>, netdev@vger.kernel.org,
	Stefan Rompf <stefan@loplof.de>, Zhu Yi <yi.zhu@intel.com>,
	James Ketrenos <jketreno@linux.intel.com>,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:38921 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S964896AbWGTDJc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2006 23:09:32 -0400
To: Dan Williams <dcbw@redhat.com>
Content-Disposition: inline
In-Reply-To: <1153356597.2542.7.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 19, 2006 at 08:49:57PM -0400, Dan Williams wrote:
> On Wed, 2006-07-19 at 10:28 -0400, Ralf Baechle wrote:
> > I got the driver to die several times under the extreme condition at the
> > KS / OLS with dozens to hundreds of other machines in the same room.  The
> > last kernel message I got from about the time when wireless died was
> > 
> >   eth1: NETDEV_TX_BUSY returned; driver should report queue full via ieee_device->is_queue_full.
> 
> I actually get this quite a bit too, at least a couple times per day.
> Sometimes the device goes down and you have to rmmod ipw2200, other
> times it recovers.  But quite annoying anyway.
> 
> Anyone know exactly what that message means, and possibly how to fix it?

For what it is worth, there was a patch for this posted back
in January.  It stirred-up a kerfluffle, so it never got merged.
FWIW, it touches on 802.11e QoS and multiple TX queues -- my personal
favorite wireless subject...NOT!

The thread is available here (first post not connected to follow-up
thread for some reason):

	http://marc.theaimsgroup.com/?l=linux-netdev&m=113809246102858&w=2
	http://marc.theaimsgroup.com/?l=linux-netdev&m=113814103024576&w=2

Given that half a year has passed, does anyone have any better ideas
now?  Should I merge the patch?  Or is the cure worse than the disease?

John
-- 
John W. Linville
linville@tuxdriver.com
