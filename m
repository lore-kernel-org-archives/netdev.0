From: John Heffner <jheffner@psc.edu>
Subject: Re: The ultimate TOE design
Date: Wed, 15 Sep 2004 19:52:25 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.NEB.4.33.0409151918320.9172-100000@dexter.psc.edu>
References: <Xine.LNX.4.44.0409151914400.32649-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Netdev <netdev@oss.sgi.com>, <leonid.grossman@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0409151914400.32649-100000@thoron.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 15 Sep 2004, James Morris wrote:

> On Wed, 15 Sep 2004, John Heffner wrote:
>
> > The other (much nicer) solution to case (b) is to just USE A BIGGER MTU.
> > 1500 bytes is ridiculously small.  Even with a 9k MTU, the benefits of TOE
> > or TSO are nearly vanishing.
>
> Do you have any figures on (large) MTU size vs performance on a current
> commidity system?

What qualifies as large?  I ran some measurements out to 9k w/GigE a few
years ago.  (Something like 100 byte increments.)  I can try to find the
data if anyone is interested.  I may try to run a similar experiment on 10
GigE with modern hardware, and I think these cards can go out to 16k as
well.

The basic idea is that the margainal benefit (in terms of CPU cycles) of
increasing the MTU is proportional to log(MTU).  In all experiments I have
done or seen, the data agree with this, except for discontinuities due to
PCI settings, page sizes and maybe a couple other things.

There are some arguments that going to much larger MTUs could be of
substantial benefit other than CPU cycles, but this is harder to quantify.
See <http://www.psc.edu/~mathis/MTU/>.

  -John
