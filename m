From: Hasso Tepper <hasso@estpak.ee>
Subject: Re: icmp_unreachable uses wrong ip
Date: Mon, 2 May 2005 20:38:21 +0300
Message-ID: <200505022038.22014.hasso@estpak.ee>
References: <1115040079.5620.11.camel@jeroens.office.netland.nl> <200505021659.05674.hasso@estpak.ee> <42763E96.1070209@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "J. Simonetti" <jeroens@office.netland.nl>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <42763E96.1070209@trash.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Hasso Tepper wrote:
> > Similar patches have been posted to the list repeatedly AFAIK with no
> > any response from developers. Can someone enlighten us why? Is there
> > something wrong with it? This is the feature people administrating
> > routers would like to have. It makes debugging complicated topologies
> > much easier and all routers I have seen behave this way.
>
> Why can't you simply add the prefered source address to the route?

Because I don't know what it is. Router A knows what's the best path from=
=20
router A to router B, but he can't know (at least in cases where there ar=
e=20
more than 1 path between them) what's the best path from router B to rout=
er=20
A. Therefore you can=E4t say which one is incoming interface in router A =
for=20
traffic from router B. And even if you know it in some moment, topology=20
might change in next moment (dynamic routing) etc.

--=20
Hasso
