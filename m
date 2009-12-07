From: Frederic Leroy <fredo@starox.org>
Subject: Re: [PATCHv3 1/2] tcp: Stalling connections: Fix timeout
 calculation routine
Date: Mon, 7 Dec 2009 20:09:04 +0100
Message-ID: <20091207200904.5f6e145a@houba>
References: <4B1C4C25.1070104@tvk.rwth-aachen.de>
	<4B1C9D94.3070504@gmail.com>
	<4B1CE45A.9010908@tvk.rwth-aachen.de>
	<4B1D27F7.9000502@tvk.rwth-aachen.de>
	<alpine.DEB.2.00.0912072046500.27565@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Damian Lukowski <damian@tvk.rwth-aachen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Greg KH <gregkh@suse.de>
To: "Ilpo =?UTF-8?B?SsOkcnZpbmVu?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-11162.dedibox.fr ([88.191.70.230]:36935 "EHLO
	sd-11162.dedibox.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757879AbZLGTJY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 14:09:24 -0500
In-Reply-To: <alpine.DEB.2.00.0912072046500.27565@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Mon, 7 Dec 2009 20:50:11 +0200 (EET),
"Ilpo J=C3=A4rvinen" <ilpo.jarvinen@helsinki.fi> a =C3=A9crit :

> On Mon, 7 Dec 2009, Damian Lukowski wrote:
>=20
> > This patch fixes a problem in the TCP connection timeout
> > calculation. Currently, timeout decisions are made on the basis of
> > 6fa12c85031485dff38ce550c24f10da23b0adaa.
> [...]
>> >  static inline struct sk_buff *tcp_send_head(struct sock *sk)=20
>=20
> Acked-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
>=20
> Also, this should be added:
>=20
> Reported-by: Frederic Leroy <fredo@starox.org>
>=20
> ...and I think he has already tested this fix a number of times in=20
> different forms, so I'd already include his Tested-by: too.

If you need a bad connection to do some test, don't hesitate !
Thank you guys ;)

--=20
=46r=C3=A9d=C3=A9ric Leroy
