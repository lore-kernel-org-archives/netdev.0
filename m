From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC] TCP Vegas for 2.6
Date: Tue, 9 Mar 2004 10:22:06 -0800
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040309102206.33c1720c@dell_ss3.pdx.osdl.net>
References: <20040309180331.GC11604@wotan.suse.de>
	<Pine.NEB.4.33.0403091307090.5230-100000@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@suse.de>, linux-net <linux-net@vger.kernel.org>,
	<netdev@oss.sgi.com>
Return-path: <linux-net-owner@vger.kernel.org>
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <Pine.NEB.4.33.0403091307090.5230-100000@dexter.psc.edu>
List-Id: netdev.vger.kernel.org

On Tue, 9 Mar 2004 13:11:11 -0500 (EST)
John Heffner <jheffner@psc.edu> wrote:

> On Tue, 9 Mar 2004, Andi Kleen wrote:
> 
> > > I would be very cautious about turning on Vegas by default.  In certain
> > > cases, it is exactly the right thing to do.  However, in many cases it is
> > > not.  Vegas will end up losing when competing against regular Reno-ish
> > > congestion control.  Vegas also has issues with timer granularity, and
> > > tuning its parameters can be quite tricky.  There are a number of unusual
> > > failure modes as well, such as responding to congestion on the reverse
> > > path, or caused by cross traffic.
> >
> > It would be better to make it a per route flag than a global sysctl
> > at least.
> 
> This makes sense to me.  One of the primary uses of Vegas I see in high
> performance networking is as a work-around for grossly overbuffered
> routers.  This give the right level of control for that purpose.
> 
>   -John

Every case I tested has vegas faster than the default reno.  It is especially
noticeable over the DSL.  The current implementation is not ready to be turned
on by default though.

-- 
Stephen Hemminger 		mailto:shemminger@osdl.org
Open Source Development Lab	http://developer.osdl.org/shemminger
