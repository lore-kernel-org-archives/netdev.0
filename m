From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix dev dev_ethtool_get_rx_csum() for forced
 NETIF_F_RXCSUM
Date: Mon, 04 Apr 2011 11:07:19 -0700 (PDT)
Message-ID: <20110404.110719.43025693.davem@davemloft.net>
References: <20110401.202335.260089653.davem@davemloft.net>
	<20110404141443.GA26686@rere.qmqm.pl>
	<1301928880.2807.4.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mirq-linux@rere.qmqm.pl, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59156
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755150Ab1DDSHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2011 14:07:55 -0400
In-Reply-To: <1301928880.2807.4.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 04 Apr 2011 15:54:40 +0100

> On Mon, 2011-04-04 at 16:14 +0200, Micha=A9=A9 Miros=A9=A9aw wrote:
>> On Fri, Apr 01, 2011 at 08:23:35PM -0700, David Miller wrote:
>> > From: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
>> > Date: Thu, 31 Mar 2011 11:58:08 +0200 (CEST)
>> > > dev_ethtool_get_rx_csum() won't report rx checksumming when it's=
 not
>> > > changeable and driver is converted to hw_features and friends. F=
ix this.
>> > >=20
>> > > (dev->hw_features & NETIF_F_RXCSUM) check is dropped - if the
>> > > ethtool_ops->get_rx_csum is set, then driver is not coverted, ye=
t.
>> > >=20
>> > > Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.p=
l>
>> > Applied, thanks.
>>=20
>> I noticed this didn't get into your net-next tree (it's only in net)=
=2E
>> This impacts the hw_features conversions that are in net-next.
>>=20
>> BTW, what's the policy for this kind of patches? I send them relativ=
e
>> to net-next normally and note if this is also for -rc/stable - is th=
is
>> The Good Way(tm)?
>=20
> If you want a change to be included in the upcoming release, it must =
be
> applied initially to net-2.6; therefore it must be based on net-2.6.
>=20
> David will periodically merge net-2.6 into net-next-2.6.  You can
> probably do a test merge yourself if you want to see what the result
> will be.

I've just merged net-2.6 into net-next-2.6, so anything which exists in
net-2.6 will show up in net-next-2.6 now too.
