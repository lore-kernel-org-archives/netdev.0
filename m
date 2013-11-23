From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Fw: [Bug 65261] New: Packet loss or excessive packet delay
 repeatedly for some seconds
Date: Sat, 23 Nov 2013 20:31:51 +0000
Message-ID: <1385238711.20467.75.camel@deadeye.wl.decadent.org.uk>
References: <20131120122316.77ce76c5@nehalam.linuxnetplumber.net>
	 <20131123043359.GC15822@order.stressinduktion.org>
	 <20131123121140.GB28775@tansi.org>
	 <1385225158.20467.70.camel@deadeye.wl.decadent.org.uk>
	 <20131123202046.GB715@tansi.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-xyBypScgNn1kevUFyNsX"
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: Arno Wagner <arno@wagner.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:54007 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756301Ab3KWUcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Nov 2013 15:32:03 -0500
In-Reply-To: <20131123202046.GB715@tansi.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-xyBypScgNn1kevUFyNsX
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2013-11-23 at 21:20 +0100, Arno Wagner wrote:
> On Sat, Nov 23, 2013 at 17:45:58 CET, Ben Hutchings wrote:
> > On Sat, 2013-11-23 at 13:11 +0100, Arno Wagner wrote:
> > > On Sat, Nov 23, 2013 at 05:33:59 CET, Hannes Frederic Sowa wrote:
> > [...]
> > > > Could you try dropwatch while the packet drops are happening?
> > > > Often it is helpful to check ip monitor all if events happen during=
 bursty
> > > > losses.
> > >=20
> > > Sorry, but dropwatch is not in Debian and compiling it from sources
> > > seem to require something called "rpmbuild". Hence I cannot use
> > > it or at least would have to write my own Makefile for it.=20
> >=20
> > You could use 'perf script net_dropmonitor' instead.
>=20
> That gets me "invalid or unsupported event: 'skb:kfree_skb'"
> with 3.10.17, so I guess it will not work with 3.10.19 either.

That is probably an obscure way of saying 'permission denied'; I see the
same if I don't run it as root.

Ben.

--=20
Ben Hutchings
The generation of random numbers is too important to be left to chance.
                                                            - Robert Coveyo=
u

--=-xyBypScgNn1kevUFyNsX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUpEQt+e/yOyVhhEJAQpXwQ/9H/4JcSWM1VfZo8VUA0lFsoLeoSR47D9N
H7jAp8zfB6Vua2nLKucBBCfEe0DzYVNDHeI+WqJL77sjfzXnKAprLA0OI6oynQcv
kixup3tzS8G0ag4hJAEVCid29J0KqxDbK7MJ3DEA2grjvFJ6tY6jJCmS8cEmmyUD
Ibr5M/7x6H8CRRc6PSCqGvOvtTjYgw5TGCFE+rzOtHRIDIVqSWucyZdbX2xiwTtx
Vv/KNwK1+OuHYz2rZcycjBqV+M7+4l51+3KicL7gKWF3CpA2CTNYLcYnXmLfXTmG
7XznNb+NrISVEVh3/pHpL52DBIiQu6O59UjBDcqtS7ToRRYSuKFP5OZaDH5kcr+q
v/i8nUdKvZZD4oxdAj0M5ni0nJ++Oj13HmIaHCcGDl0p52wSvikvArQsFA+WcDdd
1PMjaUOnuHF+NrqGB/BE5RTkqJj7D4apljSIz0wwtb7bvzsnHEODFt+vBYVmFB4s
4eQpBBrjIzR/qAWFkBr/GC+EgvEXYbsjJI9FzDT2PJqDjPEKzsIrzNnWIwOBPqeR
8Hu0q72lMysXssqpQk5993irC2i+xrbsy+mRsC5zWe/Dxo0FxSvYUeAXZigy5xfS
0X3RjRTj/pHCy3VNeyhtvnM9KmWbRV1duRIgIaw4R7jB1uK4B8C6Up8xESOZk/7c
pIXJEPRw6sQ=
=ebO4
-----END PGP SIGNATURE-----

--=-xyBypScgNn1kevUFyNsX--
