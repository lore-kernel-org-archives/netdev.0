From: jamal <hadi@cyberus.ca>
Subject: Re: looking for help with scanning of IPv6 interfaces
Date: Mon, 18 Nov 2002 21:31:17 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0211182127440.14927-100000@shell.cyberus.ca>
References: <20021115235200.B8265@wotan.suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Donald Becker <becker@scyld.com>,
   Michael Richardson <mcr@sandelman.ottawa.on.ca>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20021115235200.B8265@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




You forgot the draft, Andi. Although doesnt document every little detail
(someone should) -- it goes a long way to describe the architecture and
concepts behind netlink.
A not final version:
ftp://oa.znyx.com/pub/jamal/draft-ietf-forces-netlink-04.txt

cheers,
jamal

On Fri, 15 Nov 2002, Andi Kleen wrote:

> > > Physical devices are read using /proc/net/dev
> > ...
> > > That is the old fashioned way.
> > >
> > > The new fashioned one is to query them using rtnetlink. You use a RTM_GETADDR
> > > NLM_F_REQUEST query with wildcard (NLM_F_ROOT) to get a full list.
> > > See the netlink,rtnetlink, libnetlink manpages and iproute2 as an example.
> > > It is easier when you use libnetlink.
> >
> > Do you have a snippet of code?
>
> Check iproute2 or zebra source. iproute2 has a libnetlink which is quite useful.
>
> I also wrote some manpages (netlink(3),netlink(7),rtnetlink(7) etc, but
> admittedly they are not very good)
>
> > What kernel version does this start working?
>
> Somewhere in Linux 2.1.<late number>
> >
> > Of course for code that needs to work with already deployed systems, you
> > need to have code for the old method around anyway...
>
> Only when you still want to support 2.0. Ok some people do not enable
> netlink in their kernel configuration, but many modern distributions
> require it for booting now (because the network init scripts use iproute2),
> so this shouldn't be a big issue anymore.
>
> -Andi
>
>
