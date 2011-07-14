From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 07/10] net: remove NETIF_F_NO_CSUM feature
Date: Wed, 13 Jul 2011 17:48:49 -0700
Message-ID: <20110713174849.41dd634d@nehalam.ftrdhcpuser.net>
References: <cover.1310601401.git.mirq-linux@rere.qmqm.pl>
	<aa24cb5cdd3bd082d038960efd7d5c9a2ba95d8e.1310601401.git.mirq-linux@rere.qmqm.pl>
	<1310603009.2756.8.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50356 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751204Ab1GNAsy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 20:48:54 -0400
In-Reply-To: <1310603009.2756.8.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Jul 2011 01:23:29 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Thu, 2011-07-14 at 02:10 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> > There are no explicit users, so this is now equivalent to NETIF_F_H=
W_CSUM.
> [...]
>=20
> I think this is still a useful distinction, even the networking core
> currently doesn't care about the difference.
>=20
> Ben.

It also is a kernel API change since this part is exposed
through ethtool calls.
