From: Pasi =?iso-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>
Subject: Re: [PATCH] tcp: frto should not set snd_cwnd to 0
Date: Wed, 6 Feb 2013 23:21:04 +0200
Message-ID: <20130206212104.GX8912@reaktio.net>
References: <CADVnQymufg8YFCg3cBQzTW-WbYRYpG=FVqtd-A5tLUU=Uex_eg@mail.gmail.com>
 <20130206.155504.1553906005129825120.davem@davemloft.net>
 <20130206211343.GW8912@reaktio.net>
 <20130206.161919.1732889798702305226.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ncardwell@google.com, ilpo.jarvinen@helsinki.fi,
	eric.dumazet@gmail.com, hannes@stressinduktion.org,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	ycheng@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.tele.fi ([192.89.123.25]:50812 "EHLO smtp.tele.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757956Ab3BFVVH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2013 16:21:07 -0500
Content-Disposition: inline
In-Reply-To: <20130206.161919.1732889798702305226.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 06, 2013 at 04:19:19PM -0500, David Miller wrote:
> From: Pasi K=E4rkk=E4inen <pasik@iki.fi>
> Date: Wed, 6 Feb 2013 23:13:43 +0200
>=20
> > On Wed, Feb 06, 2013 at 03:55:04PM -0500, David Miller wrote:
> >> From: Neal Cardwell <ncardwell@google.com>
> >> Date: Tue, 5 Feb 2013 14:49:04 -0500
> >>=20
> >> > On Mon, Feb 4, 2013 at 7:14 AM, Ilpo J=E4rvinen <ilpo.jarvinen@h=
elsinki.fi> wrote:
> >> >> [PATCH 1/1] tcp: fix for zero packets_in_flight was too broad
> >> >>
> >> >> There are transients during normal FRTO procedure during which
> >> >> the packets_in_flight can go to zero between write_queue state
> >> >> updates and firing the resulting segments out. As FRTO processi=
ng
> >> >> occurs during that window the check must be more precise to
> >> >> not match "spuriously" :-). More specificly, e.g., when
> >> >> packets_in_flight is zero but FLAG_DATA_ACKED is true the probl=
ematic
> >> >> branch that set cwnd into zero would not be taken and new segme=
nts
> >> >> might be sent out later.
> >> >>
> >> >> Only compile tested.
> >> >>
> >> >> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
> >>  ...
> >> > Acked-by: Neal Cardwell <ncardwell@google.com>
> >>=20
> >> Applied, thanks everyone.
> >>
> >=20
> > Hmm.. are we missing CC stable@kernel.org in these patches?=20
> > I guess 3.6.x is already EOL, but it'd be nice to get this bug fixe=
d also in 3.7.x ..
>=20
> We never CC: stable on networking patches, I queue them up manually
> and submit them at a time of my own choosing.
>

OK, I didn't know that. Thanks :)

-- Pasi
