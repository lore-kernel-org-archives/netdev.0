From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] tcp: efficient port randomistion (rev 3)
Date: Wed, 22 Jun 2005 09:44:42 -0700
Message-ID: <20050622094442.65a0e1bc@dxpl.pdx.osdl.net>
References: <20041220153916.6c00c114.davem@davemloft.net>
	<200506221117.04334.michael.vittrup.larsen@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Vittrup Larsen <michael.vittrup.larsen@ericsson.com>
In-Reply-To: <200506221117.04334.michael.vittrup.larsen@ericsson.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 22 Jun 2005 11:17:03 +0200
Michael Vittrup Larsen <michael.vittrup.larsen@ericsson.com> wrote:

> On Tuesday 21 December 2004 00:39, David S. Miller wrote:
> > On Fri, 10 Dec 2004 17:09:00 -0800
> >
> > Stephen Hemminger <shemminger@osdl.org> wrote:
> > > okay, here is the revised version. Testing shows that it
> > > is more consistent, and just as fast as existing code,
> > > probably because of the getting rid of portalloc_lock and
> > > better distribution.
> > >
> > > Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> >
> > Queued up for 2.6.11, thanks Stephen.
> 
> What's the status of this - I see it is not part of 2.6.12?
> 
> Is there a general dislike of the port randomisation mechanism or?

There is port randomization in 2.6.11 and 2.6.12, look for
secure_tcp_port_ephemeral in the source. 2.6.12 also does random port
allocation for IPV6.

We still do the non-random stuff for explicit binds (tcp_v4_get_port),
but there is no state to seed in that case and it only impacts app's 
that do an explicit bind to 0.
