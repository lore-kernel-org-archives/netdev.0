From: "David S. Miller" <davem@davemloft.net>
Subject: Re: RFC/PATCH capture qdisc requeue event in stats
Date: Tue, 28 Sep 2004 17:03:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040928170315.760b9851.davem@davemloft.net>
References: <1093799632.1073.410.camel@jzny.localdomain>
	<1096413009.27967.1.camel@localhost.localdomain>
	<20040928161838.3d19a17d.davem@davemloft.net>
	<1096416101.27967.10.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <1096416101.27967.10.camel@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 28 Sep 2004 17:01:41 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> On Tue, 2004-09-28 at 16:18 -0700, David S. Miller wrote:
> > On Tue, 28 Sep 2004 16:10:09 -0700
> > Stephen Hemminger <shemminger@osdl.org> wrote:
> > 
> > > On Sun, 2004-08-29 at 13:13 -0400, jamal wrote:
> > > > 
> > > > The requeue event is useful in finding out when a device is overloaded
> > > > on the egress (bus or bandwidth).
> > > > Atached patch introduces this. I would have used the overlimit bits
> > > > but at the moment thats being used for different semantical reasons.
> > > > I have not done extensive testing on it. 
> > > > 
> > > > Opinions welcome - If all is good, Dave please apply.
> > > 
> > > Dave, what happened to this?  I put the stuff into iproute2 but the
> > > requeue stat never made it into 2.6.  Is it a bad idea?
> > 
> > Yes, API breaker.
> 
> Well it seems to work for me:
> 	  kernel
>         New	Old
> tc New  Ok      Ok(0)
>    Old  Ok(0)   Ok
> 
> Because tc correctly handles the returned TLV size.

Because tc has all the length checking stuff added to
it, other applications using netlink might not.  The
whole world is not 'tc'.

I'm just rehashing how the most recent thread between
Jamal and myself ended about this topic.
