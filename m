From: John Heffner <jheffner@psc.edu>
Subject: Re: [RFT] BIC TCP delayed ack compensation
Date: Wed, 23 Feb 2005 17:19:06 -0500 (EST)
Message-ID: <Pine.LNX.4.58.0502231713360.28189@dexter.psc.edu>
References: <052Q0TU11@server5.heliogroup.fr> <200502231835.j1NIZX2T020606@uni07mr.unity.ncsu.edu>
 <20050223112611.60561121.davem@davemloft.net> <Pine.LNX.4.58.0502231436170.28189@dexter.psc.edu>
 <20050223141032.56793f88.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: hubert.tonneau@fullpliant.org, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050223141032.56793f88.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 23 Feb 2005, David S. Miller wrote:

> On Wed, 23 Feb 2005 17:04:08 -0500 (EST)
> John Heffner <jheffner@psc.edu> wrote:
>
> > Maybe this has something to do with the bi-directional nature of the flow?
> > Mac OS delaying ACK to try to piggyback on data or something like that.
> > One signature I noticed is that it seems the last packet sent by the Mac
> > before the long delack timeout is always a small data packet.  (I didn't
> > rigorously verify this but it seems true.)
>
> I should be more specific when I say "PSH".  Mac OS-X's algorithm is basically
> that it always delays ACKs to the delayed ACK timeout when the header prediction
> fast path is hit.  One way to "miss" the header prediction fast path is to
> set PSH (this is actually a bug, Linux fixed this long ago, PSH should be ignored
> for header prediction fast path checking).

The point is it appears to be delaying ack even when PSH is set.


> Anyways, this Mac OS-X behavior has pretty much been universally agreed
> to as a severe bug, at least on this list :-)

Yep.  The Mac behavior is clearly bizarre. :)

  -John
