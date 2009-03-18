From: YOSHIFUJI Hideaki <yoshfuji@st-paulia.net>
Subject: Re: PROBLEM: IPv6 autoconf/accept_ra default values
Date: Wed, 18 Mar 2009 12:33:08 +0900 (JST)
Message-ID: <20090318.123308.29370828.yoshfuji@st-paulia.net>
References: <alpine.LNX.2.00.0902241031470.28298@halbrend.uninett.no>
	<alpine.LNX.2.00.0903180200590.10453@firda.kolla.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: linux@kolla.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from sapphire.linux-ipv6.org ([203.178.140.14]:53953 "EHLO
	sapphire.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752443AbZCRDzV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 23:55:21 -0400
In-Reply-To: <alpine.LNX.2.00.0903180200590.10453@firda.kolla.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

In article <alpine.LNX.2.00.0903180200590.10453@firda.kolla.no> (at Wed=
, 18 Mar 2009 02:06:09 +0100 (CET)), Kolbj=F8rn Barmen <linux@kolla.no>=
 says:

> > My personal oppinion is that anything ipv6 autoconfig/accept_ra sho=
uld be
> > default _off_, since this simplifies all the above mentioned issues=
, and
> > it is incredibly easy to turn on again with systcl if people want i=
t.
> > It is much easier to enable ipv6 automagic than to disable it.
> > At least there should be kernel/module parameter to set default beh=
aviour.
> >=20
> > Part of the problem with deploying IPv6 is due to "magic" like this=
, all
> > the autoconfig/router announcement magic looks very well on paper a=
nd in
> > theory, but out in the field it quickly leads to loads of totally
> > unnecessary extra work, work that could easily be avoided if defaul=
t
> > behaviour was to have it off. It should be in the interest of IPv6
> > advocates to support a "soft" transition from IPv4-only to dual-sta=
ck,
> > fencing off unwanted "magic" only adds to the frustration for those=
 who
> > actually try to deploy it.
> >=20
> > What do you think?
>=20
> Obviously noone really think much of this, one way or the other, so h=
ere's a
> patch that changes the default values.

Default should be ON.

But I would agree to have some (relatively easy) way to disable
autoconfiguration.  Well yes, probably kernel module papameter.

Simple interface:
 - disable_ipv6=3D1
 - autoconf=3D0

Do anyone need more complex interface?
 - disable_ipv6=3D{all|IF}:0,...
 - autoconf=3D{all|IF}:0,...

--yoshfuji
