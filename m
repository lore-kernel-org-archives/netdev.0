From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH 00/18] netfilter: IPv6 NAT
Date: Wed, 30 Nov 2011 00:05:09 +0000
Message-ID: <1322611509.2684.52.camel@bwh-desktop>
References: <CAF9AA63.1622%ulrich.weber@sophos.com>
	 <a2407c3b6405bd682cedad6db82cf225@treenet.co.nz>
	 <4ED4A399.6090709@sophos.com>
	 <alpine.LNX.2.01.1111291255200.20965@frira.zrqbmnf.qr>
	 <4ED550E7.1090609@ans.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan Engelhardt <jengelh@medozas.de>,
	Ulrich Weber <ulrich.weber@sophos.com>,
	Amos Jeffries <squid3@treenet.co.nz>,
	"sclark46@earthlink.net" <sclark46@earthlink.net>,
	"kaber@trash.net" <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Krzysztof =?UTF-8?Q?Ol=C4=99dzki?= <ole@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:30195 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757217Ab1K3AFP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 19:05:15 -0500
In-Reply-To: <4ED550E7.1090609@ans.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-11-29 at 22:38 +0100, Krzysztof Ol=C4=99dzki wrote:
> On 2011-11-29 13:23, Jan Engelhardt wrote:
> >
> > On Tuesday 2011-11-29 10:19, Ulrich Weber wrote:
> >> On 28.11.2011 23:03, Amos Jeffries wrote:
> >>> I'm going to dare to call FUD on those statements...
> >>>    * Load Balancing - what is preventing your routing rules or pa=
cket
> >>>   marking using the same criteria as the NAT changer? nothing. Lo=
ad
> >>>   balancing works perfectly fine without NAT.
> >
> > Source address selection, having to occur on the source, would
> > require that the source has to know all the parameters that a {what
> > would have been your NAT GW} would need to know, which means you ha=
ve
> > to (a) collect and/or (b) distribute this information. Given two
> > uplinks that only allow a certain source network address (different
> > for each uplink), combined with the desire to balance on utilizatio=
n,
> > (a) a client is not in the position to easily obtain this data unle=
ss
> > it is the router for all participants itself, (b) the clients needs
> > to cooperate, and one cannot always trust client devices, or hope f=
or
> > their technical cooperation (firewalled themselves off).
> >
> > Yes, NAT is evil, but if you actually think about it, policies are
> > best applied where [the policy] originates from. After all, we also
> > don't do LSRR, instead, routers do the routing, because they just
> > know much better.
> >
> >> I fully agree. NAT can not replace your firewall rules.
> >>
> >> However with NAT you could get some kind of anonymity.
> >
> > Same network prefix, some cookies, or a login form. Blam, identifie=
d,
> > or at least (Almost-)Uniquely Identified Visitor tagging.
>=20
> But without NAT you have pretty big chance to have the same IPv6=20
> *suffix* everywhere, based on you MAC address. In your Home, your Wor=
k,=20
> in a Cafe or in a hotel during your vacations in Portugal. So yes, NA=
T=20
> is not a perfect solution but it really helps you privacy.

If you enable NAT on your own network, how does this help when you use
all those other networks that may not use NAT or may have a predictable
mapping from MAC address to public IPv6 address?

Instead you need to deal with this on the mobile device itself, using
the RFC3041 privacy extensions.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
