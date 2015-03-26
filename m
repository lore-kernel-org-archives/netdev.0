From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: IPv6 nexthop for IPv4
Date: Thu, 26 Mar 2015 11:43:36 -0400
Message-ID: <20150326154336.GA2528@tuxdriver.com>
References: <CAJO99T=uXuaYP5QCRYbU7iRhK7S8UqW9GfmL1J2yBh1N2TDjYg@mail.gmail.com>
 <CACP96tQnQ5d2qrPbs+S640S=r07vnbt-RmL_O2zT7Wcvg99dug@mail.gmail.com>
 <CAJO99TmhNARZL4L2KzMHLdqhXFh8LYb+mussWvaiCN4KQpim=Q@mail.gmail.com>
 <CACP96tQAYZEq=cFyDNBkgzUbJ_VPJB540ZxgaRqpciujCYOjsA@mail.gmail.com>
 <CAJO99Tm+ex7aELCrNnubWz1hGjELMp0LCMKSqtyr+Vci1hrmuw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sowmini Varadhan <sowmini05@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: =?iso-8859-1?Q?Bj=F8rnar?= Ness <bjornar.ness@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57710 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752415AbbCZPpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 11:45:15 -0400
Content-Disposition: inline
In-Reply-To: <CAJO99Tm+ex7aELCrNnubWz1hGjELMp0LCMKSqtyr+Vci1hrmuw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 26, 2015 at 04:10:21PM +0100, Bj=F8rnar Ness wrote:
> 2015-03-26 15:53 GMT+01:00 Sowmini Varadhan <sowmini05@gmail.com>:
> > On Thu, Mar 26, 2015 at 10:39 AM, Bj=F8rnar Ness <bjornar.ness@gmai=
l.com> wrote:
> >
> >>>> ip route add 10.0.0.0/16 via fe80::225:90ff:fed3:bfb4/64 dev sfp=
0
> >>>
> >>> Trying to understand what the desired behavior is, for the route
> >>> above: if I send a packet from 10.0.0.1 to 10.0.0.2, you want the=
 dst-mac
> >>> to be the mac address of e80::225:90ff:fed3:bfb4???
> >>
> >> Absolutely, correct.
> >
> > What if the current node does not want to support ipv6? This sounds
> > pretty "creative", if this can work, you might as well make the nex=
thop to
> > be the L2 address of the gw.
>=20
> If it does not support IPv6 I guess the route command will fail! This
> is a bad argument
> against this. Dont see the point of limiting nexthop to L2

This topic was discussed at the recent Netconf event in Ottawa.
This is a viable means of interconnecting two IPv4 "island" subnets
across an IPv6 "ocean" backplane.

Andy Gospodarek gave a short discussion on the topic, and IIRC it
was warmly received.  I'll Cc him on this message -- I think he had a
(fairly simple) patch more or less ready.

Hth!

John
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
