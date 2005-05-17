From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Wed, 18 May 2005 09:25:56 +1000
Message-ID: <20050517232556.GA26846@gondor.apana.org.au>
References: <E1DYBED-0006wa-00@gondolin.me.apana.org.au> <Pine.LNX.4.61.0505171612440.3335@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dlstevens@us.ibm.com, rick.jones2@hp.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arthur Kepner <akepner@sgi.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0505171612440.3335@linux.site>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, May 17, 2005 at 04:20:07PM -0700, Arthur Kepner wrote:
> On Wed, 18 May 2005, Herbert Xu wrote:
> 
> > ....
> > Such systems would be violating the spirit of RFC791 which says:
> > 
> >     The identification field is used to distinguish the fragments of one
> >     datagram from those of another.  The originating protocol module of
> >     an internet datagram sets the identification field to a value that
> >     must be unique for that source-destination pair and protocol for the
> >     time the datagram will be active in the internet system.
> > 
> > Are you aware of any extant systems that do this?
> > ....
> 
> Are you aware of any (new) systems that _don't_ violate this? I 
> wouldn't want to own one of them! 

Perhaps you misunderstood what I was saying.  I meant are there any
extant systems that would transmit 1 set of fragments to host A with
id x, then 65535 packets host B, and then wrap around and send a new
set of fragments to host A with idx.

Linux will never do this thanks to inetpeer.c.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
