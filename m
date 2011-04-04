From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: Fix dev dev_ethtool_get_rx_csum() for forced
 NETIF_F_RXCSUM
Date: Mon, 04 Apr 2011 15:54:40 +0100
Message-ID: <1301928880.2807.4.camel@bwh-desktop>
References: <f658c6e20dad946b50fda008c120a0347ad58314.1301565174.git.mirq-linux@rere.qmqm.pl>
	 <20110401.202335.260089653.davem@davemloft.net>
	 <20110404141443.GA26686@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:40925 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754628Ab1DDOyn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2011 10:54:43 -0400
In-Reply-To: <20110404141443.GA26686@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-04-04 at 16:14 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> On Fri, Apr 01, 2011 at 08:23:35PM -0700, David Miller wrote:
> > From: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> > Date: Thu, 31 Mar 2011 11:58:08 +0200 (CEST)
> > > dev_ethtool_get_rx_csum() won't report rx checksumming when it's =
not
> > > changeable and driver is converted to hw_features and friends. Fi=
x this.
> > >=20
> > > (dev->hw_features & NETIF_F_RXCSUM) check is dropped - if the
> > > ethtool_ops->get_rx_csum is set, then driver is not coverted, yet=
=2E
> > >=20
> > > Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl=
>
> > Applied, thanks.
>=20
> I noticed this didn't get into your net-next tree (it's only in net).
> This impacts the hw_features conversions that are in net-next.
>=20
> BTW, what's the policy for this kind of patches? I send them relative
> to net-next normally and note if this is also for -rc/stable - is thi=
s
> The Good Way(tm)?

If you want a change to be included in the upcoming release, it must be
applied initially to net-2.6; therefore it must be based on net-2.6.

David will periodically merge net-2.6 into net-next-2.6.  You can
probably do a test merge yourself if you want to see what the result
will be.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

