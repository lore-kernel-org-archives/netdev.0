From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Re: [PATCH] ipv4: arp_notify address list bug
Date: Wed, 7 Oct 2009 07:49:14 +1030
Message-ID: <20091007074914.7803f182@opy.nosense.org>
References: <20091005191505.75c929a6@nehalam>
	<4ACAB5BC.1020307@gmail.com>
	<20091005.213103.237708475.davem@davemloft.net>
	<4ACAD393.5080909@gmail.com>
	<20091006082913.54883824@nehalam>
	<4ACB65B8.2050106@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.adam.net.au ([202.136.110.253]:58062 "EHLO
	smtp1.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933328AbZJFVUA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 17:20:00 -0400
In-Reply-To: <4ACB65B8.2050106@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 06 Oct 2009 17:43:52 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Stephen Hemminger a =E9crit :
> >=20
> > Okay, but I can't see that sending out one per address is going to =
be a big
> > storm. Can't imagine user with 100's of addresses on same interface=
, but I guess
> > it is possible.
> >=20
>=20
> I saw some setups with hundred of ip addresses.
>=20
> But they probably dont change MAC addresses very often :)
>=20
> Who knows...

Colo shared webhosts with per customer/site https/SSL certificates coul=
d
be an example.

