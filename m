From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next 5/5] ifb: convert to 64 bit stats
Date: Mon, 20 Jun 2011 14:38:13 -0700
Message-ID: <20110620143813.233f1642@nehalam.ftrdhcpuser.net>
References: <20110620203506.363818794@vyatta.com>
	<20110620.135607.2158729745388010853.davem@davemloft.net>
	<20110620141253.00249218@nehalam.ftrdhcpuser.net>
	<1308604980.2658.23.camel@edumazet-laptop>
	<1308605221.2658.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jamal <hadi@cyberus.ca>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35710 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755402Ab1FTViP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 17:38:15 -0400
In-Reply-To: <1308605221.2658.25.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 20 Jun 2011 23:27:01 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le lundi 20 juin 2011 =E0 23:23 +0200, Eric Dumazet a =E9crit :
> > Le lundi 20 juin 2011 =E0 14:12 -0700, Stephen Hemminger a =E9crit =
:
> > > Convert input functional block device to use 64 bit stats.
> > >=20
> > > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > >=20
> > > ---
> > > v2 - add stats_sync
> > >=20
> >=20
> > Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
> >=20
>=20
> Ah well, I am wondering if ri_tasklet() & ifb_xmit() could run
> concurrently
>=20
> If so, we need two separate syncp, one for each function.

=46or the normal case that isn't possible but
someone could be perverse and put an address on the ifb device and
try and use like loopback?
