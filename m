From: Maciej Soltysiak <solt@dns.toxicfilms.tv>
Subject: Re: ipv6 stack seems to forget to send ACKs
Date: Wed, 8 Jan 2003 17:39:36 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0301081718340.4542-100000@dns.toxicfilms.tv>
References: <20030108150201.GA30490@wiggy.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Wichert Akkerman <wichert@wiggy.net>
In-Reply-To: <20030108150201.GA30490@wiggy.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Previously Wichert Akkerman wrote:
> > traceroute to ipv6.lkml.org (2001:968:1::2) from
> > 3ffe:8280:10:1d0:290:27ff:fe2d:968c, 30 hops max, 16 byte packets
> >  1  thunder.wiggy.net (3ffe:8280:10:1d0:250:4ff:fe0b:dd79)  0.666 ms 0.22 ms  0.199 ms
> >  2  xs4all-29.ipv6.xs4all.nl (3ffe:8280:0:2001::58)  27.568 ms  28.012 ms  30.177 ms
> >  3  26.ge-0-2-0.xr1.pbw.xs4all.net (2001:888:0:3::1)  22.035 ms 19.528 ms  44.644 ms
> >  4  0.ge-0-3-0.xr1.sara.xs4all.net (2001:888:2:1::1)  19.519 ms 19.002 ms  21.974 ms
> >  5  fe-0-0-0.ams-core-01.network6.isp-services.nl (2001:7f8:1::a502:4875:1)  19.978 ms  30.278 ms  20.248 ms
> >  6  2001:968::2 (2001:968::2)  24.246 ms  24.083 ms  22.918 ms
> >  7  2001:968:1::2 (2001:968:1::2)  24.978 ms  23.866 ms  23.661 ms
> >
> > thunder.wiggy.net is my Linux router running 2.4.19-pre5-ac3-freeswan196
> > currently. The second hop is a normal sit tunnel and all the other
> > hops are native ipv6 using Cisco and Juniper routers as far as I know.
>
> Slight correction to that: xs4all-29.ipv6.xs4all.nl is a FreeBSD-4.5
> tunnel server. The toher xs4all.net hops are Junipers running JunOS 5.3
> or 5.5.
I had four contiguous listenings:
3 mins
10mins
19mins
13mins

When i increased the buffer in xmms i got better uninterrupted timings.
And survived data gaps better.

I seem to be getting better results than you, i think that it is not an
issue of ipv6 implementation but simply the case of time sensitive
traffic fighting with other Internet traffic over tunnels through ipv4
networks.

I do not know how many tunnels are in my path, i know that hop distance to
my tunnel is exactly 1 hop (ipv6 broker and ipv4 provider are the same)

If there is immense traffic at one of the routers (total traffic on an
interface) stream packets can be simply dropped if there are no queuing
disciplines that would take eg. flow control into account.

What do you think?

btw. what the hell is JunOs ?

Regards,
Maciej Soltysiak
