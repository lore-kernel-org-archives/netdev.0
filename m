From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: IPv6 nexthop for IPv4
Date: Thu, 26 Mar 2015 12:27:59 -0400
Message-ID: <20150326162756.GC1051@gospo>
References: <CAJO99T=uXuaYP5QCRYbU7iRhK7S8UqW9GfmL1J2yBh1N2TDjYg@mail.gmail.com>
 <CACP96tQnQ5d2qrPbs+S640S=r07vnbt-RmL_O2zT7Wcvg99dug@mail.gmail.com>
 <CAJO99TmhNARZL4L2KzMHLdqhXFh8LYb+mussWvaiCN4KQpim=Q@mail.gmail.com>
 <CACP96tQAYZEq=cFyDNBkgzUbJ_VPJB540ZxgaRqpciujCYOjsA@mail.gmail.com>
 <CAJO99Tm+ex7aELCrNnubWz1hGjELMp0LCMKSqtyr+Vci1hrmuw@mail.gmail.com>
 <20150326154336.GA2528@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sowmini Varadhan <sowmini05@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>,
	=?iso-8859-1?Q?Bj=F8rnar?= Ness <bjornar.ness@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f48.google.com ([209.85.213.48]:35959 "EHLO
	mail-yh0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002AbbCZQ2G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 12:28:06 -0400
Received: by yhjf44 with SMTP id f44so28707428yhj.3
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 09:28:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150326154336.GA2528@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 26, 2015 at 11:43:36AM -0400, John W. Linville wrote:
> On Thu, Mar 26, 2015 at 04:10:21PM +0100, Bj=F8rnar Ness wrote:
> > 2015-03-26 15:53 GMT+01:00 Sowmini Varadhan <sowmini05@gmail.com>:
> > > On Thu, Mar 26, 2015 at 10:39 AM, Bj=F8rnar Ness <bjornar.ness@gm=
ail.com> wrote:
> > >
> > >>>> ip route add 10.0.0.0/16 via fe80::225:90ff:fed3:bfb4/64 dev s=
fp0
> > >>>
> > >>> Trying to understand what the desired behavior is, for the rout=
e
> > >>> above: if I send a packet from 10.0.0.1 to 10.0.0.2, you want t=
he dst-mac
> > >>> to be the mac address of e80::225:90ff:fed3:bfb4???
> > >>
> > >> Absolutely, correct.
> > >
> > > What if the current node does not want to support ipv6? This soun=
ds
> > > pretty "creative", if this can work, you might as well make the n=
exthop to
> > > be the L2 address of the gw.
> >=20
> > If it does not support IPv6 I guess the route command will fail! Th=
is
> > is a bad argument
> > against this. Dont see the point of limiting nexthop to L2
>=20
> This topic was discussed at the recent Netconf event in Ottawa.
> This is a viable means of interconnecting two IPv4 "island" subnets
> across an IPv6 "ocean" backplane.
>=20
> Andy Gospodarek gave a short discussion on the topic, and IIRC it
> was warmly received.  I'll Cc him on this message -- I think he had a
> (fairly simple) patch more or less ready.

Yes, I do have one!  I was working on some other issues and need to
rebase it based on Eric's recent work.  It was fairly simple and the
netlink changes are also not too difficult so the patch to iproute2 was
small.

I have an older patch you can see here:

https://github.com/gospo/net-next/commit/7f602a54424f453872b6a45ae5ed4d=
3a601db91d

Shall I rebase and post to the list for all to see?
