From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: OSDL Bugzilla #2399: A user can remotely route a packet through
 eth0 on a Li
Date: Thu, 13 May 2004 10:56:57 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0405131048460.10245@localhost.localdomain>
References: <BAY15-F5TPEFoxcC3U000054055@hotmail.com>
 <20040513103139.08ebc779@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "J. M." <snortwiz@hotmail.com>, niv@us.ibm.com, dlstevens@us.ibm.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040513103139.08ebc779@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

But if a service is bound to a particular ip address, i guess requests
coming on other ip addresses will not be accepted.

For ex: i have 2 hosts with the following set of ip addresses.
host1: 10.1.1.19, 10.1.2.19
host2: 10.1.1.20, 10.1.2.20

I ran
	iperf -B 10.1.1.19 -s
on host1
Here we are binding iperf to a particular ip address: 10.1.1.19

>From host2 i tried,
	iperf -c 10.1.1.20
and it failed as expected.

Is this different from the scenario raised in the original bug report?

Thanks
Sridhar

On Thu, 13 May 2004, Stephen Hemminger wrote:

> On Thu, 13 May 2004 12:20:34 -0500
> "J. M." <snortwiz@hotmail.com> wrote:
>
> > That's exactly what's happening - a service bound to an interface is
> > receiving traffic via a different interface.  That could pose security risks
> > on a dual-homed machine (such as the device I pen-tested and discovered this
> > flaw upon).
> >
> > -Jared
>
> On Linux, IP addresses are not bound to interfaces.  You need
> to use SO_BINDTODEVICE if that is what you want.
>
> The security model is correct, and well defined, just different than BSD
> derived systems.  It does conform to the standards (RFC's).
>
>
