From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: fec: fix spelling mistake "coalesed" -> "coalesced"
Date: Sat, 04 Jun 2016 23:36:35 -0700
Message-ID: <1465108595.11800.55.camel@perches.com>
References: <1465066875-7089-1-git-send-email-colin.king@canonical.com>
	 <CADFy_4GNq-VQj5kgFsoCiHJTHTo21ZdjijfD=mEM602YCrewEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fugang Duan <fugang.duan@nxp.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Augusto Mecking Caringi <augustocaringi@gmail.com>,
	Colin King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0138.hostedemail.com ([216.40.44.138]:32955 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752018AbcFEGgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2016 02:36:39 -0400
In-Reply-To: <CADFy_4GNq-VQj5kgFsoCiHJTHTo21ZdjijfD=mEM602YCrewEw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-06-04 at 16:43 -0300, Augusto Mecking Caringi wrote:
> On Sat, Jun 4, 2016 at 4:01 PM, Colin King <colin.king@canonical.com>=
 wrote:
> > From: Colin Ian King <colin.king@canonical.com>
> > trivial fix to spelling mistake in pr_err message
[]
> > diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/ne=
t/ethernet/freescale/fec_main.c
[]
> > @@ -2427,13 +2427,13 @@ fec_enet_set_coalesce(struct net_device *nd=
ev, struct ethtool_coalesce *ec)
> >=20
> > =A0=A0=A0=A0=A0=A0=A0=A0cycle =3D fec_enet_us_to_itr_clock(ndev, fe=
p->rx_time_itr);
> > =A0=A0=A0=A0=A0=A0=A0=A0if (cycle > 0xFFFF) {
> > -=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0pr_err("Rx coalesed u=
sec exceeed hardware limiation");
> > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0pr_err("Rx coalesced =
usec exceeed hardware limiation");
> > =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0return -EINVAL;
> > =A0=A0=A0=A0=A0=A0=A0=A0}
> >=20
> > =A0=A0=A0=A0=A0=A0=A0=A0cycle =3D fec_enet_us_to_itr_clock(ndev, fe=
p->tx_time_itr);
> > =A0=A0=A0=A0=A0=A0=A0=A0if (cycle > 0xFFFF) {
> > -=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0pr_err("Rx coalesed u=
sec exceeed hardware limiation");
> > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0pr_err("Rx coalesced =
usec exceeed hardware limiation");
> > =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0return -EINVAL;
> > =A0=A0=A0=A0=A0=A0=A0=A0}
> >=20
> s/limiation/limitation

Could also add \n terminations to the pr_err uses.
