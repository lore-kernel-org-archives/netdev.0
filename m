From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6 0/9] net: Unified offload configuration
Date: Thu, 17 Feb 2011 14:56:11 -0800 (PST)
Message-ID: <20110217.145611.229745070.davem@davemloft.net>
References: <cover.1297824704.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51386
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751665Ab1BQWze (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 17:55:34 -0500
In-Reply-To: <cover.1297824704.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Wed, 16 Feb 2011 03:59:16 +0100 (CET)

> Here's a v6 of the ethtool unification patch series.
>=20
> What's in it?
>  1..4:
> 	cleanups for the core patches
>  5:
> 	the patch - implement unified ethtool setting ops
>  6..7:
> 	implement interoperation between old and new ethtool ops
>  8:
> 	include RX checksum in features and plug it into new framework
>  9:
> 	convert loopback device to new framework
>=20
> What is it good for?
>  - unifies driver behaviour wrt hardware offloads
>  - removes a lot of boilerplate code from drivers
>  - allows better fine-grained control over used offloads

Applied to net-next-2.6, please send any bug fixes relative to this.

Please get rid of that annoying message spit out by netif_features_chan=
ge(),
it's just spam.  If we want notifications for stuff like this, use a
non-unicast netlink message so those who want to hear it can do so.
