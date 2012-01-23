From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: ethtool: allow ETHTOOL_GSSET_INFO for users
Date: Mon, 23 Jan 2012 01:19:17 +0000
Message-ID: <1327281557.8004.137.camel@deadeye>
References: <197ddc79ac33a67c56b42a226af3f30056bceb5c.1327227549.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:60266 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752528Ab2AWBT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2012 20:19:27 -0500
In-Reply-To: <197ddc79ac33a67c56b42a226af3f30056bceb5c.1327227549.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-01-22 at 11:20 +0100, Micha=C5=82 Miros=C5=82aw wrote:
> Allow ETHTOOL_GSSET_INFO ethtool ioctl() for unprivileged users.
> ETHTOOL_GSTRINGS is already allowed, but is unusable without this one=
=2E
>=20
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
Acked-by: Ben Hutchings <bhutchings@solarflare.com>

We should probably also add:

ETHTOOL_GLINK
ETHTOOL_GRXFHINDIR
ETHTOOL_GCHANNELS

Ben.

> ---
>  net/core/ethtool.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>=20
> [against net, but probably suitable for stable, too]
>=20
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index 921aa2b..369b418 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -1311,6 +1311,7 @@ int dev_ethtool(struct net *net, struct ifreq *=
ifr)
>  	case ETHTOOL_GRXCSUM:
>  	case ETHTOOL_GTXCSUM:
>  	case ETHTOOL_GSG:
> +	case ETHTOOL_GSSET_INFO:
>  	case ETHTOOL_GSTRINGS:
>  	case ETHTOOL_GTSO:
>  	case ETHTOOL_GPERMADDR:

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
