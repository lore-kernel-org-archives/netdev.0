From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool: ETHTOOL_SFEATURES: remove NETIF_F_COMPAT
 return
Date: Fri, 27 May 2011 15:13:46 +0100
Message-ID: <1306505626.2759.4.camel@bwh-desktop>
References: <20110516.140958.625993829749556424.davem@davemloft.net>
	 <20110519100331.GA25103@rere.qmqm.pl> <20110524091437.GA10779@rere.qmqm.pl>
	 <20110524.153930.610330240390616957.davem@davemloft.net>
	 <20110524215923.GA20138@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:18721 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753582Ab1E0ONt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2011 10:13:49 -0400
In-Reply-To: <20110524215923.GA20138@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-05-24 at 23:59 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> On Tue, May 24, 2011 at 03:39:30PM -0400, David Miller wrote:
> > From: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> > Date: Tue, 24 May 2011 11:14:37 +0200
> >=20
> > > On Thu, May 19, 2011 at 12:03:31PM +0200, Micha=C5=82 Miros=C5=82=
aw wrote:
> > >> On Mon, May 16, 2011 at 02:09:58PM -0400, David Miller wrote:
> > >> > You guys really need to sort this out properly.
> > >> > Please resubmit whatever final solution is agreed upon.
> > >> I noticed that v2.6.39 was tagged today. We should definitely re=
move
> > >> NETIF_F_COMPAT so it won't bite us in the future. The other patc=
h that
> > >> fixes ethtool_ops->set_flags compatibility is a bugfix, so it sh=
ould go
> > >> in - if we decide that the SFEATURES compatibility should be rem=
oved
> > >> it won't matter.
> > >>=20
> > >> Ben, do you agree?
> > > Ping?
> > > http://patchwork.ozlabs.org/patch/95552/
> > > (this is a bugfix, so should go to stable)
> > >=20
> > > http://patchwork.ozlabs.org/patch/95753/
> > > (removes ETHTOOL_F_COMPAT; this we need to decide on)
> > You and Ben are still arguing over details.
> >=20
> > I want fresh versions of these patches (yes, both of them) once
> > all of the issues are resolved.
>=20
> We could just wait for 2.6.40 and pretend this code part never existe=
d. ;-)

I think I will make ethtool check for a minimum kernel version of 2.6.4=
0
before using ETHTOOL_{G,S}FEATURES.

> I'll rebase the first patch tomorrow. Without it the compatibility in
> ETHTOOL_SFEATURES for non-converted drivers is busted wrt set_flags.

This is an improvement, but I still think the fallback is fundamentally
broken - there's no good way for userland to tell what (if anything)
went wrong when the return value has ETHTOOL_F_COMPAT set.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

