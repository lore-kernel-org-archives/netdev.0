From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH] net: Fix dev dev_ethtool_get_rx_csum() for forced
	NETIF_F_RXCSUM
Date: Mon, 4 Apr 2011 16:14:43 +0200
Message-ID: <20110404141443.GA26686@rere.qmqm.pl>
References: <f658c6e20dad946b50fda008c120a0347ad58314.1301565174.git.mirq-linux@rere.qmqm.pl> <20110401.202335.260089653.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:46645 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754145Ab1DDOOp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 10:14:45 -0400
Content-Disposition: inline
In-Reply-To: <20110401.202335.260089653.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 01, 2011 at 08:23:35PM -0700, David Miller wrote:
> From: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> Date: Thu, 31 Mar 2011 11:58:08 +0200 (CEST)
> > dev_ethtool_get_rx_csum() won't report rx checksumming when it's no=
t
> > changeable and driver is converted to hw_features and friends. Fix =
this.
> >=20
> > (dev->hw_features & NETIF_F_RXCSUM) check is dropped - if the
> > ethtool_ops->get_rx_csum is set, then driver is not coverted, yet.
> >=20
> > Signed-off-by: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> Applied, thanks.

I noticed this didn't get into your net-next tree (it's only in net).
This impacts the hw_features conversions that are in net-next.

BTW, what's the policy for this kind of patches? I send them relative
to net-next normally and note if this is also for -rc/stable - is this
The Good Way(tm)?

Best Regards,
Micha=B3 Miros=B3aw
