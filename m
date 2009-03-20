From: David Miller <davem@davemloft.net>
Subject: Re: PROBLEM: IPv6 autoconf/accept_ra default values
Date: Thu, 19 Mar 2009 23:44:46 -0700 (PDT)
Message-ID: <20090319.234446.242594797.davem@davemloft.net>
References: <alpine.LNX.2.00.0902241031470.28298@halbrend.uninett.no>
	<alpine.LNX.2.00.0903180200590.10453@firda.kolla.no>
	<20090318.123308.29370828.yoshfuji@st-paulia.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux@kolla.no, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: yoshfuji@st-paulia.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57261
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751315AbZCTGo7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2009 02:44:59 -0400
In-Reply-To: <20090318.123308.29370828.yoshfuji@st-paulia.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: YOSHIFUJI Hideaki <yoshfuji@st-paulia.net>
Date: Wed, 18 Mar 2009 12:33:08 +0900 (JST)

> In article <alpine.LNX.2.00.0903180200590.10453@firda.kolla.no> (at W=
ed, 18 Mar 2009 02:06:09 +0100 (CET)), Kolbj=F8rn Barmen <linux@kolla.n=
o> says:
>=20
> > > My personal oppinion is that anything ipv6 autoconfig/accept_ra s=
hould be
> > > default _off_, since this simplifies all the above mentioned issu=
es, and
> > > it is incredibly easy to turn on again with systcl if people want=
 it.
> > > It is much easier to enable ipv6 automagic than to disable it.
> > > At least there should be kernel/module parameter to set default b=
ehaviour.
> > >=20
> > > Part of the problem with deploying IPv6 is due to "magic" like th=
is, all
> > > the autoconfig/router announcement magic looks very well on paper=
 and in
> > > theory, but out in the field it quickly leads to loads of totally
> > > unnecessary extra work, work that could easily be avoided if defa=
ult
> > > behaviour was to have it off. It should be in the interest of IPv=
6
> > > advocates to support a "soft" transition from IPv4-only to dual-s=
tack,
> > > fencing off unwanted "magic" only adds to the frustration for tho=
se who
> > > actually try to deploy it.
> > >=20
> > > What do you think?
> >=20
> > Obviously noone really think much of this, one way or the other, so=
 here's a
> > patch that changes the default values.
>=20
> Default should be ON.

I absolutely agree.

It can't be called autoconfiguration if it's off by default, and
you have to "configure" something.

What are people smoking? :-)

