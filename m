From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] TCP Vegas for 2.6
Date: 09 Mar 2004 13:58:06 -0500
Sender: linux-net-owner@vger.kernel.org
Message-ID: <1078858686.1036.726.camel@jzny.localdomain>
References: <20040309180331.GC11604@wotan.suse.de>
	 <Pine.NEB.4.33.0403091307090.5230-100000@dexter.psc.edu>
	 <20040309102206.33c1720c@dell_ss3.pdx.osdl.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: John Heffner <jheffner@psc.edu>, Andi Kleen <ak@suse.de>,
	linux-net <linux-net@vger.kernel.org>, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040309102206.33c1720c@dell_ss3.pdx.osdl.net>
List-Id: netdev.vger.kernel.org

On Tue, 2004-03-09 at 13:22, Stephen Hemminger wrote:

> Every case I tested has vegas faster than the default reno.  It is especially
> noticeable over the DSL. ]

As i am sure you will notice it even more on ppp/dial up. I am suprised
on the DSL results though. 
Theres tons of literature has already been written on this stuff. It is
know that Reno will work better over Vegas in some cases (as pointed
above). Its useful to have vegas as a feature but lets not jump the gun.
Congestion control algorithms have been known to start religious wars.

>  The current implementation is not ready to be turned
> on by default though.

i like Andis idea of being able to select per route.

cheers,
jamal

