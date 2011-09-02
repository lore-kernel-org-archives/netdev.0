From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC, 1/2] ethtool: Implement private flags interface for
 ethtool application.
Date: Fri, 02 Sep 2011 22:34:32 +0100
Message-ID: <1314999272.3419.19.camel@bwh-desktop>
References: <1314996631-4773-1-git-send-email-carolyn.wyborny@intel.com>
	 <20110902.165524.1076389492712310664.davem@davemloft.net>
	 <EDC0E76513226749BFBC9C3FB031318F0173FF8607@orsmsx508.amr.corp.intel.com>
	 <CAHXqBFKU2m6s1fQzZpJRvvR2HatJpXjWXv84=ZYD5E6OPFfUmQ@mail.gmail.com>
	 <CAHXqBF+9iP6tOmtiaXopGvLyBZvpXmLz05aHj1MrQ2RnAiGGLA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:29650 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756024Ab1IBVef convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2011 17:34:35 -0400
In-Reply-To: <CAHXqBF+9iP6tOmtiaXopGvLyBZvpXmLz05aHj1MrQ2RnAiGGLA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-09-02 at 23:22 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> W dniu 2 wrze=C5=9Bnia 2011 23:17 u=C5=BCytkownik Micha=C5=82 Miros=C5=
=82aw
> <mirqus@gmail.com> napisa=C5=82:
> > 2011/9/2 Wyborny, Carolyn <carolyn.wyborny@intel.com>:
> >>>-----Original Message-----
> >>>From: David Miller [mailto:davem@davemloft.net]
> >>>Sent: Friday, September 02, 2011 1:55 PM
> >>>To: Wyborny, Carolyn
> >>>Cc: bhutchings@solarflare.com; netdev@vger.kernel.org
> >>>Subject: Re: [RFC, 1/2] ethtool: Implement private flags interface=
 for
> >>>ethtool application.
> >>>
> >>>From: Carolyn Wyborny <carolyn.wyborny@intel.com>
> >>>Date: Fri,  2 Sep 2011 13:50:30 -0700
> >>>
> >>>> This patch completes the user space implementation of the privat=
e
> >>>> flags inteface in ethtool. Using -b/-B options.
> >>>>
> >>>> Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
> >>>
> >>>The only use case you show here is something generic which other
> >>>chips have, Energy Efficient Ethernet.
> >>>
> >>>Making an attribute private which is present widely amonst various
> >>>networking chips makes no sense at all.
> >>>
> >>>It deserved a generic ethtool flag.
> >>
> >> Fair enough on this particular feature, but does that negate the i=
mplementation suggestion altogether?  I can send an updated feature imp=
lementation for the use case using DMA Coalescing if that will help.
> > I would rather see this as an extension to ETHTOOL_[GS]FEATURES. It=
s
> > semantics allow easy expanding to handle device-private flags witho=
ut
> > changing anything on userspace side.
>=20
> BTW, After pending Intel drivers get converted to ndo_set_features an=
d
> netdev->features get extended to 64 bits, it would also be possible t=
o
> use some of the unused bits there for device/driver-private flags
> almost "for free".

I don't really like the idea of mixing common feature flags with
driver-specific flags.  It's likely to lead to confusion if you mix
devices with different drivers in a bridge or a bond.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
