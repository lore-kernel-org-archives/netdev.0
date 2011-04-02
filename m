From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix dev dev_ethtool_get_rx_csum() for forced
 NETIF_F_RXCSUM
Date: Fri, 01 Apr 2011 20:23:35 -0700 (PDT)
Message-ID: <20110401.202335.260089653.davem@davemloft.net>
References: <f658c6e20dad946b50fda008c120a0347ad58314.1301565174.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45001
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752207Ab1DBDYP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 23:24:15 -0400
In-Reply-To: <f658c6e20dad946b50fda008c120a0347ad58314.1301565174.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Thu, 31 Mar 2011 11:58:08 +0200 (CEST)

> dev_ethtool_get_rx_csum() won't report rx checksumming when it's not
> changeable and driver is converted to hw_features and friends. Fix th=
is.
>=20
> (dev->hw_features & NETIF_F_RXCSUM) check is dropped - if the
> ethtool_ops->get_rx_csum is set, then driver is not coverted, yet.
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied, thanks.
