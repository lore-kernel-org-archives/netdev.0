From: John Heffner <jheffner@psc.edu>
Subject: Re: [RFC] TCP Vegas for 2.6
Date: Tue, 9 Mar 2004 12:52:14 -0500 (EST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.NEB.4.33.0403091234380.5230-100000@dexter.psc.edu>
References: <20040308134542.62320cae@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-net <linux-net@vger.kernel.org>, <netdev@oss.sgi.com>
Return-path: <linux-net-owner@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040308134542.62320cae@dell_ss3.pdx.osdl.net>
List-Id: netdev.vger.kernel.org

On Mon, 8 Mar 2004, Stephen Hemminger wrote:

> On Mon, 8 Mar 2004 22:36:46 +0100
> Andi Kleen <ak@suse.de> wrote:
>
> > > CONFIG options are of no use vendors who need to ship binary kernels.
> >
> > I can well see a vendor trading scalability for experimental non standard TCP
> > algorithms that tend to be disabled anyways.
>
> If Vegas proves to be as reliable in Linux as BSD, it probably will be the
> default.

I'm curious what you mean about BSD.

I would be very cautious about turning on Vegas by default.  In certain
cases, it is exactly the right thing to do.  However, in many cases it is
not.  Vegas will end up losing when competing against regular Reno-ish
congestion control.  Vegas also has issues with timer granularity, and
tuning its parameters can be quite tricky.  There are a number of unusual
failure modes as well, such as responding to congestion on the reverse
path, or caused by cross traffic.

  -John

