From: John Heffner <jheffner@psc.edu>
Subject: Re: [RFC] TCP Vegas for 2.6
Date: Tue, 9 Mar 2004 13:11:11 -0500 (EST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.NEB.4.33.0403091307090.5230-100000@dexter.psc.edu>
References: <20040309180331.GC11604@wotan.suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephen Hemminger <shemminger@osdl.org>,
	linux-net <linux-net@vger.kernel.org>, <netdev@oss.sgi.com>
Return-path: <linux-net-owner@vger.kernel.org>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040309180331.GC11604@wotan.suse.de>
List-Id: netdev.vger.kernel.org

On Tue, 9 Mar 2004, Andi Kleen wrote:

> > I would be very cautious about turning on Vegas by default.  In certain
> > cases, it is exactly the right thing to do.  However, in many cases it is
> > not.  Vegas will end up losing when competing against regular Reno-ish
> > congestion control.  Vegas also has issues with timer granularity, and
> > tuning its parameters can be quite tricky.  There are a number of unusual
> > failure modes as well, such as responding to congestion on the reverse
> > path, or caused by cross traffic.
>
> It would be better to make it a per route flag than a global sysctl
> at least.

This makes sense to me.  One of the primary uses of Vegas I see in high
performance networking is as a work-around for grossly overbuffered
routers.  This give the right level of control for that purpose.

  -John

