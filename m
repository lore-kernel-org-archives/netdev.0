From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH] IPv6: Improvement of Source Address Selection
Date: Sat, 28 Sep 2002 08:24:58 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0209280813030.8846-100000@netcore.fi>
References: <200209280500.JAA02974@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@redhat.com, <yoshfuji@linux-ipv6.org>,
   <linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>,
   <usagi@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200209280500.JAA02974@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 28 Sep 2002 kuznet@ms2.inr.ac.ru wrote:
> > route, as there would have to be at least two candidates there.
> ...
> > Am I missing something obvious here?
> 
> Yes. You select some one of the candidates eventually, do not you? :-)

But can there be more candidates for one route, in which case one would 
run something similar to this algorithm then?

Or would you have an already-sorted list of possible candidate addresses 
for each route in the order of preference?  And recalculate always when 
address changes?

Or..?

> And when you have some special preference for a subnet you create
> a route for it.

This is IMO a wrong approach from user's perspective.  Perhaps not if the 
algorithm was run and e.g. additional, temporary "address selection" 
routes were created by kernel.
 
> > (stuff that's network prefix -independent
> 
> I am sorry, I feel I do not understand what you mean.

Hmm.. this depends on the interpretation of the concept above.  If the
list is refreshed always when addresses change or change state, this could
perhaps work..

-- 
Pekka Savola                 "Tell me of difficulties surmounted,
Netcore Oy                   not those you stumble over and fall"
Systems. Networks. Security.  -- Robert Jordan: A Crown of Swords
