From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 07/10] net: remove NETIF_F_NO_CSUM feature
Date: Thu, 14 Jul 2011 01:59:47 +0100
Message-ID: <1310605187.2756.14.camel@bwh-desktop>
References: <cover.1310601401.git.mirq-linux@rere.qmqm.pl>
	 <aa24cb5cdd3bd082d038960efd7d5c9a2ba95d8e.1310601401.git.mirq-linux@rere.qmqm.pl>
	 <1310603009.2756.8.camel@bwh-desktop>
	 <20110713174849.41dd634d@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:9796 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751204Ab1GNA7v convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 20:59:51 -0400
In-Reply-To: <20110713174849.41dd634d@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-07-13 at 17:48 -0700, Stephen Hemminger wrote:
> On Thu, 14 Jul 2011 01:23:29 +0100
> Ben Hutchings <bhutchings@solarflare.com> wrote:
>=20
> > On Thu, 2011-07-14 at 02:10 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> > > There are no explicit users, so this is now equivalent to NETIF_F=
_HW_CSUM.
> > [...]
> >=20
> > I think this is still a useful distinction, even the networking cor=
e
> > currently doesn't care about the difference.
> >=20
> > Ben.
>=20
> It also is a kernel API change since this part is exposed
> through ethtool calls.

Users of ETHTOOL_{G,S}FEATURES are supposed to use the corresponding
string set to map names to bits (and vice versa).  It is OK to renumber
features, and to remove them if they are no longer implemented.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

