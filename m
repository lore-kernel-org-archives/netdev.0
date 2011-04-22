From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] net: fix hw_features ethtool_ops->set_flags
 compatibility
Date: Thu, 21 Apr 2011 17:21:59 -0700 (PDT)
Message-ID: <20110421.172159.179943760.davem@davemloft.net>
References: <1303413559.3165.55.camel@bwh-desktop>
	<20110421221548.GA7888@rere.qmqm.pl>
	<20110421235921.89D1D13909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	eric.dumazet@gmail.com, vladz@broadcom.com, eilong@broadcom.com
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36656
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753550Ab1DVAWe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 20:22:34 -0400
In-Reply-To: <20110421235921.89D1D13909@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Fri, 22 Apr 2011 01:59:21 +0200 (CEST)

> __ethtool_set_flags() was not taking into account features set but no=
t
> user-toggleable.
>=20
> Since GFLAGS returns masked dev->features, EINVAL is returned when
> passed flags differ to it, and not to wanted_features.
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
> ---
> This should be the simpler way Ben was talking about.

Applied, thanks.
