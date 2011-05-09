From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/bonding: adjust codingstyle for bond_3ad files
Date: Sun, 08 May 2011 17:12:04 -0700 (PDT)
Message-ID: <20110508.171204.27789908.davem@davemloft.net>
References: <BANLkTik_gMCHYp4sOnzzR1Gs=bn2pkpjfQ@mail.gmail.com>
	<20110508.161012.258121848.davem@davemloft.net>
	<BANLkTimao-Zyk6ypW3UxzqtsgmQ-6qvYng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mfmooney@gmail.com, joe@perches.com, aquini@linux.com,
	kernel-janitors@vger.kernel.org, fubar@us.ibm.com,
	andy@greyhouse.net, shemminger@vyatta.com, netdev@vger.kernel.org,
	nikai@nikai.net
To: hlovdal@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38061
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754234Ab1EIAMh convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 May 2011 20:12:37 -0400
In-Reply-To: <BANLkTimao-Zyk6ypW3UxzqtsgmQ-6qvYng@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: H=E5kon L=F8vdal <hlovdal@gmail.com>
Date: Mon, 9 May 2011 02:08:41 +0200

> void bond_3ad_state_machine_handler(struct work_struct *work)
> {
>         struct bonding *bond =3D container_of(work, struct bonding,
>                                             ad_work.work);
>         struct port *port;
>         struct aggregator *aggregator;
>=20
>         read_lock(&bond->lock);
>=20
>         if (! bond->kill_timers) {
>=20
>                 //check if there are any slaves
>                 if (bond->slave_cnt !=3D 0) {
>                         ...
>                 }
>                 queue_delayed_work(bond->wq, &bond->ad_work, ad_delta=
_in_ticks);
>         }
>         read_unlock(&bond->lock);
> }
>=20
>=20
> And this was what I trying to reccommend against (and which the
> stackoverflow question is about).

I really don't see anything wrong with either approach.

