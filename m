From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool: ETHTOOL_SFEATURES: remove NETIF_F_COMPAT
 return
Date: Mon, 16 May 2011 14:37:46 +0100
Message-ID: <1305553066.19966.32.camel@localhost>
References: <20110516121339.GA1094@rere.qmqm.pl>
	 <1305335142.2851.70.camel@bwh-desktop> <20110514103539.GA5214@rere.qmqm.pl>
	 <1305513923.19966.20.camel@localhost>
	 <20110516132807.1A89F13A6A@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:12318 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755270Ab1EPNhv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 09:37:51 -0400
In-Reply-To: <20110516132807.1A89F13A6A@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-05-16 at 15:28 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> Remove NETIF_F_COMPAT since it's redundant and will be unused after
> all drivers are converted to fix/set_features.
>=20
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> ---
>=20
> For net as we don't want to have ETHTOOL_F_COMPAT hit stable release.
[...]

ETHTOOL_F_WISH means that the requested features could not all be
enabled, *but are remembered*.  ETHTOOL_F_COMPAT means they were not
remembered.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

