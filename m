From: Cliff White <cliffw@osdl.org>
Subject: Re: Network driver test suite?
Date: Thu, 13 Jan 2005 07:29:43 -0800
Message-ID: <200501131529.j0DFThm26355@mail.osdl.org>
References: <20050112101001.20ccc59d@dxpl.pdx.osdl.net>
Cc: Craig Thomas <craiger@osdl.org>, David Hollis <dhollis@davehollis.com>,
        netdev@oss.sgi.com, cliff white <cliffw@osdl.org>, cliffw@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: Your message of "Wed, 12 Jan 2005 10:10:01 PST."
             <20050112101001.20ccc59d@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> On Wed, 12 Jan 2005 09:14:01 -0800
> Craig Thomas <craiger@osdl.org> wrote:
> 
> > On Wed, 2005-01-12 at 08:24, David Hollis wrote:
> > > On Tue, 2005-01-11 at 17:32 -0800, Craig Thomas wrote:
> > > 
> > > > 
> > > > Would there be a desire for someone to collect the tests or at least
> > > > create an index to all their locations?  If so, then developers can
> > > > scan a library of potential tests to run against newly developed code.
> > > > 
> > > > OSDL can start incorporating some of these tests into their test
> > > > platform as well.
> > > 
> > > I would love to see a collection of the types of tests that should be
> > > performed.  As it appears now, there is nothing defined that a driver
> > > author should do to verify that their driver performs properly, or
> > > supports the right capabilities etc.  Some things may be difficult to
> > > automate, but simply having a checklist would be great.  For the things
> > > that can be automated, that would be even better.
> > 
> > Great.  We can do some of this.  I would like to ask, what mimimal
> > types of tests do you expect to execute for a driver?  If several
> > can respond to the types of testing they perform, we can start
> > a checklist.  Then, additional items can be added to fill in the
> > holes.  I've asked Cliff White of OSDL to help put this together.
> 
> There are two types of tests that would be easy to set up.
> First is a full exercise of all the possible API transitions through
> ifconfig, ip link, and ethtool. These could be covered without any
> traffic going through.
> 
> Then setup a standard test environment with a known good card and a
> crossover cable.  The test could then use raw (and/or packet generator)
> to send packets down good card to card to be verified.
> 
> Also testing, auto negotiation and transitions under load.

Okay, I'll see what i can do to start putting together a list of 
tests requirements. 
cliffw
