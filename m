From: alex@pilosoft.com
Subject: Re: Do you know the TCP stack? (127.x.x.x routing)
Date: Sun, 6 Mar 2005 12:12:05 -0500 (EST)
Message-ID: <Pine.LNX.4.44.0503061210020.12011-100000@bawx.pilosoft.com>
References: <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Martin Mares <mj@ucw.cz>, <netdev@oss.sgi.com>,
	<linux-net@vger.kernel.org>
To: Zdenek Radouch <zdenek@rcn.com>
In-Reply-To: <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 6 Mar 2005, Zdenek Radouch wrote:

> seems to be hidden, i.e., it actually is treated in a special way
> by one of the entities I am perusing.
> Let's see if I can delete the route anyway.
> 
>     svfx:~# route del -net 127.0.0.0 netmask 255.0.0.0 dev lo
>     SIOCDELRT: No such process
>     svfx:~# 
> 
> That actually looks like some compatibility issue if I had to guess.
> I never used the iproute tools, so I'll ignore that for now.
> [Anyone knows what this means?]
> and/or the netstat/route/iproute tools are in flux, i.e., being changed
> in a major way to the point that I really need to pay attention to what
> kernel I am running.  I have done the above tests on my "stable"
> machine, which runs 2.2.20 (common Debian stable release). I'll go and
> retest everything on my embedded target which is running the 2.4.25
> kernel.
That's like testing on a yugo. Make sure after upgrading to 2.4, you also 
get iproute2 toolchain.

> Can someone comment on the stability of the tools in question
> or any implementation changes in this area that would explain
> the above behavior?
On 2.4.27, once you delete 127.x address from the interface, traffic will 
go as expected to another route...

