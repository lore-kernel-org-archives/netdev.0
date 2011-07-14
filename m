From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 09/10] net: remove /sys/class/net/*/features
Date: Wed, 13 Jul 2011 18:16:57 -0700
Message-ID: <20110713181657.7ee907a1@nehalam.ftrdhcpuser.net>
References: <cover.1310601401.git.mirq-linux@rere.qmqm.pl>
	<ce3c2d463fa75fe00052658cf29e73375f965ab7.1310601401.git.mirq-linux@rere.qmqm.pl>
	<20110713175037.7cbf772a@nehalam.ftrdhcpuser.net>
	<1310605439.2756.17.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48257 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752977Ab1GNBRB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 21:17:01 -0400
In-Reply-To: <1310605439.2756.17.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Jul 2011 02:03:59 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Wed, 2011-07-13 at 17:50 -0700, Stephen Hemminger wrote:
> > On Thu, 14 Jul 2011 02:10:30 +0200 (CEST)
> > Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl> wrote:
> >=20
> > > The same information and more can be obtained by using ethtool
> > > with ETHTOOL_GFEATURES.
> > >=20
> > > Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl=
>
> >=20
> > Changing user visible API has to go through a longer process
> > such as putting it in feature-removal-schedule.txt for a while
> > (at couple of releases) before removing.
>=20
> We already established that this ABI has been changed repeatedly by
> renumbering of features.

Ok, but we still should have maintained compatibly with mapping.
