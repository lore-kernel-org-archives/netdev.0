From: "Leonid Grossman" <leonid.grossman@neterion.com>
Subject: RE: [PATCH 0/9]: TCP: The Road to Super TSO
Date: Wed, 8 Jun 2005 15:19:34 -0700
Message-ID: <200506082219.j58MJYVG002386@guinness.s2io.com>
References: <20050608.144906.77057282.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, <herbert@gondor.apana.org.au>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'David S. Miller'" <davem@davemloft.net>, <jheffner@psc.edu>
In-Reply-To: <20050608.144906.77057282.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 

> -----Original Message-----
> From: netdev-bounce@oss.sgi.com 
> [mailto:netdev-bounce@oss.sgi.com] On Behalf Of David S. Miller
> Sent: Wednesday, June 08, 2005 2:49 PM
> To: jheffner@psc.edu
> Cc: netdev@oss.sgi.com; herbert@gondor.apana.org.au
> Subject: Re: [PATCH 0/9]: TCP: The Road to Super TSO
> 
> From: John Heffner <jheffner@psc.edu>
> Subject: Re: [PATCH 0/9]: TCP: The Road to Super TSO
> Date: Wed, 8 Jun 2005 17:40:10 -0400
> 
> > On Tuesday 07 June 2005 12:08 am, David S. Miller wrote:
> > > Some folks, notable the S2IO guys, get performance 
> degradation from 
> > > the Super TSO v2 patch (they get it from the first 
> version as well).  
> > > It's a real pain to spot what causes such things in such a huge 
> > > patch... so I started splitting things up in a very fine grained 
> > > manner so we can catch regressions more precisely.
> > 
> > I'm curious about the details of this.  Is there decreased 
> performance 
> > relative to current TSO?  Relative to no TSO?  Sending to just one 
> > receiver or many, and is it receiver limited?
> 
> The receiver is limited in their tests.  No current 
> generation systems can fill a 10gbit pipe fully, especially 
> at 1500 byte MTU.

With jumbo frames, a single receiver can handle 10GbE line rate.
With 1500 mtu, a single receiver becomes a bottleneck. I will forward the
numbers later today.


> 
> Performance went down, with both TSO enabled and disabled, 
> compared to not having the patches applied.
> 
> That's why I'm going through this entire exercise of doing 
> things one piece at a time.
> 
> 
