From: Hasso Tepper <hasso@estpak.ee>
Subject: Re: icmp_unreachable uses wrong ip
Date: Tue, 3 May 2005 09:44:48 +0300
Message-ID: <200505030944.49175.hasso@estpak.ee>
References: <1115040079.5620.11.camel@jeroens.office.netland.nl> <200505022038.22014.hasso@estpak.ee> <4276A400.2050306@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "J. Simonetti" <jeroens@office.netland.nl>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4276A400.2050306@trash.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Hasso Tepper wrote:
> > Patrick McHardy wrote:
> >>Why can't you simply add the prefered source address to the route?
> >
> > Because I don't know what it is. Router A knows what's the best path
> > from router A to router B, but he can't know (at least in cases where
> > there are more than 1 path between them) what's the best path from
> > router B to router A. Therefore you can=E4t say which one is incoming
> > interface in router A for traffic from router B. And even if you know
> > it in some moment, topology might change in next moment (dynamic
> > routing) etc.
>
> Your patch can't guarantee that the address used is the same that was
> used as nexthop by the previous hop in the path when multiple addresses
> are configured on the incoming interface. So I don't think it achieves
> much of your goal of making debugging complicated topologies easier.

At first I don't care what was used as nexthop. I want to know which=20
physical link was used. Having multiple addresses in the same link is mor=
e=20
corner case in core network anyway.

And can you explain what theoretical possibilities router has to obtain i=
nfo=20
what address was used as nexthop by neighbour?


regards,

--=20
Hasso Tepper
Elion Enterprises Ltd.
WAN administrator
