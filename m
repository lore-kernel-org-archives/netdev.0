From: John Heffner <jheffner@psc.edu>
Subject: Re: TCP receiver's window calculation problem
Date: Fri, 25 Jun 2004 09:43:32 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.NEB.4.33.0406250932560.2996-100000@dexter.psc.edu>
References: <Pine.LNX.4.44.0406241331590.1272-100000@orchestra.cs.caltech.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@oss.sgi.com" <netdev@oss.sgi.com>,
        "fast-support@cs.caltech.edu" <fast-support@cs.caltech.edu>
Return-path: <netdev-bounce@oss.sgi.com>
To: Cheng Jin <chengjin@cs.caltech.edu>
In-Reply-To: <Pine.LNX.4.44.0406241331590.1272-100000@orchestra.cs.caltech.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 24 Jun 2004, Cheng Jin wrote:

> The receiver is set to use a 9000 MTU, but the sender uses a 1500-byte
> MTU, which is not really a pathological case.  It would have made more
> sense for the receiver to allocate skbs of the right size as incoming
> packets are received.

Some drivers are apparently optimized for this case.  I have not confirmed
this.


> Is it due to effciency reasons that the skbs are just fixed in size
> according to the set MTU on the interface card? I suppose that the
> receiver has no real way of knowing the right MTU size at the sender.

I haven't looked too hard in to this.  Any device driver people want to
chime in?

  -John
