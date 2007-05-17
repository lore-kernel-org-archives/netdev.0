From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [stable] [PATCH 2.6.21-stable] [IPV6]: Restore semantics of
	Routing Header processing.
Date: Wed, 16 May 2007 18:46:00 -0700
Message-ID: <20070517014600.GE3429@sequoia.sous-sol.org>
References: <20070512.011728.16743460.yoshfuji@linux-ipv6.org> <20070511162243.GC3516@sequoia.sous-sol.org> <20070512.012820.126195303.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: chrisw@sous-sol.org, davem@davemloft.net, netdev@vger.kernel.org,
	stable@kernel.org
To: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-99-217-87.dsl.aracnet.com ([216.99.217.87]:39487 "EHLO
	sous-sol.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757576AbXEQBrb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 21:47:31 -0400
Content-Disposition: inline
In-Reply-To: <20070512.012820.126195303.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E (yoshfuji@li=
nux-ipv6.org) wrote:
> In article <20070511162243.GC3516@sequoia.sous-sol.org> (at Fri, 11 M=
ay 2007 09:22:43 -0700), Chris Wright <chrisw@sous-sol.org> says:
> > * YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E (yoshfuj=
i@linux-ipv6.org) wrote:
> > > The "fix" for emerging security threats was overkill and it broke
> > > basic semantic of IPv6 routing header processing.  We should assu=
me
> > > RT0 (or even RT2, depends on configuration) as "unknown" RH type =
so
> > > that we
> > > - silently ignore the routing header if segleft =3D=3D 0
> > > - or, send ICMPv6 Parameter Problem message back to the sender,
> > >   otherwise.
> >=20
> > Does that mean this one has received testing and is good for -stabl=
e
> > now, or does it need some bake time?
>=20
> Chris, I think it is okay, but
> please wait for Dave's approval.

Any update on this one?

thanks,
-chris
