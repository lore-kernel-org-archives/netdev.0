From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH] IPv6: Improvement of Source Address Selection
Date: Sun, 29 Sep 2002 11:41:23 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0209291135210.27427-100000@netcore.fi>
References: <200209280537.JAA03046@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@redhat.com, <yoshfuji@linux-ipv6.org>,
   <linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>,
   <usagi@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200209280537.JAA03046@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 28 Sep 2002 kuznet@ms2.inr.ac.ru wrote:
> > Or would you have an already-sorted list of possible candidate addresses 
> > for each route in the order of preference?
> 
> I am not mad yet. :-)
> 
> What preference? You must select _one_ address, you do not need lost
> candidates.

In the case the first entry goes away, having a list could help being able 
to the next one to use very easily.  But this probably just an 
implementation detail.

> > And recalculate always when address changes?
> 
> What address? Interface address? Routing tables used to be synchronized
> to this.

Any address.

One notable case is that the outgoing interface has only link/site-local 
addresses and the destination is global.  There are other cases too.

> > This is IMO a wrong approach from user's perspective.  Perhaps not if the 
> > algorithm was run and e.g. additional, temporary "address selection" 
> > routes were created by kernel.
> >  
> > > > (stuff that's network prefix -independent
> > > 
> > > I am sorry, I feel I do not understand what you mean.
> > 
> > Hmm.. this depends on the interpretation of the concept above.  If the
> > list is refreshed always when addresses change or change state, this could
> > perhaps work..
> 
> I am afraid I do not understand what "address", "state", "temporary" routes
> etc you mean. It remained in your brains. :-)
> 
> Pekka, are you not going to sleep? (I am.) I bet when you reread this tomorrow,
> you will not blame that my brains eventually falled to "parse error" loop. :-)

I had already woken up :-).

At least BSD and I think Linux create ad-hoc, "cloned" routes e.g. in Path
MTU discovery process to hold some different values.  I don't remember the 
details.  I was wondering if this would be done the same or not.

change state = move to deprecated, move to non-deprecated.

Hope this clarifies.

-- 
Pekka Savola                 "Tell me of difficulties surmounted,
Netcore Oy                   not those you stumble over and fall"
Systems. Networks. Security.  -- Robert Jordan: A Crown of Swords
