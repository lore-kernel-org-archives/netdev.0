From: "Chad N. Tindel" <chad@tindel.net>
Subject: Re: [Bonding-devel] Re: [bonding] compatibilty issues
Date: Tue, 30 Sep 2003 17:36:50 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030930213650.GA71877@calma.pair.com>
References: <shmulik.hen@intel.com> <200309301442.31991.shmulik.hen@intel.com> <200309301639.h8UGdqCq026858@death.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shmulik.hen@intel.com, "David S. Miller" <davem@redhat.com>,
        Jeff Garzik <jgarzik@pobox.com>, chad@tindel.net,
        bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <200309301639.h8UGdqCq026858@death.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> 	Toast the whatever_OLD guys (the backwards compat ioctls) in
> both 2.4 and 2.6.  Backwards compatibility is good, but there are
> limits, and I think these have reached their limit.
> 
> 	Keep the ABI versioning stuff in both 2.4 and 2.6.  As I've
> said, that slimmed down ifenslave really makes my mouth water in
> anticipation, but I don't think we can escape our fate that easily
> just yet.  Someday....
> 
> 	Any comments from the usual gang?

My recommendations are more towards the middle than either end.  I would
like to see us get rid of the _OLD ioctls in the 2.6 kernel specifically 
because it uses the SIOCDEVPRIVATE ioctls.  This only breaks redhat if they
are shipping with a 3 year old ifenslave.  I would like to see them stay
in 2.4 for the rest of the 2.4 tree specifically so that people who want
to run on 3 year old systems can continue to do so without us breaking
their world.

Now, that being said... who you really need buyoff from is David Miller and
Jeff Garzik, since they need to be OK with whatever you implement.  Those 
guys tend to be more conservative than me, so if you can convince them
of your plan then I won't argue with it.

> 	I'm still looking through the patch set; I generally like what
> I see, and think it's probably all good to go for 2.6 (modulo the
> various changes we're discussing).  I was thinking the same for 2.4,
> but then I had a long chat with Chad, and now he's got me worried
> about potential stability problems from such a large set of changes.

This was just a general comment.  2.4 is supposed to be a stable tree...
that is, once 2.6 becomes real, we should make a concerted effort to 
not put new features into 2.4 in an effort to keep it stable.  There are
plenty of customers in the real world that won't be moving to 2.6 for 1-2 
years, and such people are not concerned with getting the newest features...
they're most concerned with having something that is supportable and doesn't
break.

> 	I'm wondering if we should apply the set to 2.6 first, and
> give it some air time in that environment before going on to 2.4.

That doesn't seem like a bad idea to me.

> 	Unfortunately, no, it doesn't seem to be feasible to keep the
> 2.4 and 2.6 source bases identical (which I was pretty jazzed about).
> I still want to try to keep them as close as is reasonable, which is
> why I'd like to put the full cleanup set into 2.4 if we can.

Its highly un-reasonable to keep the 2.4 tree in sync with 2.6 in the
long run.  Like I said, at some point, we should stop putting new features
into 2.4... and this will be the same point at which they begin to diverge
rapidly.  Now, all that said... I don't think we're at that point yet, and 
so I have no objection with going through the pain of keeping them in
sync still.

Chad
