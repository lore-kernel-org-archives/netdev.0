From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Route cache performance under stress
Date: Mon, 2 Jun 2003 18:36:37 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16091.32021.75335.227150@robur.slu.se>
References: <20030522.015815.91322249.davem@redhat.com>
	<20030522.034058.71558626.davem@redhat.com>
	<20030522114438.GD2961@netnation.com>
	<20030522.153330.74735095.davem@redhat.com>
	<20030529205125.GA30058@netnation.com>
	<16091.11735.721251.925522@robur.slu.se>
	<20030602151852.GA6070@netnation.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
   "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: Simon Kirby <sim@netnation.com>
In-Reply-To: <20030602151852.GA6070@netnation.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Simon Kirby writes:

 > This reminds me of the situation we experienced with the dst cache
 > overflowing in early 2.2 kernels.  This was a long time ago, when our
 > traffic was only about 10 Mbits/second.  We had recently upgraded from a
 > 2.0 kernel.  The dst cache was overflowing due to a bug in the garbage
 > collector, and at the time, no messages were printed.  It took me a
 > _long_ time to figure out why connections to a server I hadn't previously
 > connected to in a while would only work every so often, and not
 > immediately like they should.  I'm affraid this approach will have a
 > similar effect, albeit (hopefully) only under an attack.

 We are given more work than we have resources for (max_size) what else than 
 refuse can we do?  But yes we have invested pretty much work already. 

 Also remember we are looking into runs were 100% of incoming traffic has one 
 new dst for every packet. So how is the situation in "real life"? 
 In case of multiple devices at least NAPI gives all devs it's share. 

 > Is it possible to have a dst LRU or a simpler approximation of such and
 > recycle dst entries rather than deallocating/reallocating them?  This
 > would relieve a lot of work from the garbage collector and avoid the
 > periodic large garbage collection latency.  It could be tuned to only
 > occur in an attack (I remember Alexey saying that the deferred garbage
 > collection was implemented to reduce latency in normal opreation).

 I don't see how this can be done. Others may?

 Cheers.
						--ro
 
