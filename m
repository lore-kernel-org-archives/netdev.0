From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6.22 1/3] [TCP]: Sed magic converts func(sk, tp,
 ...) -> func(sk, ...)
Date: Mon, 16 Apr 2007 17:32:05 +0200
Message-ID: <462396F5.9030907@trash.net>
References: <1176727728729-git-send-email-ilpo.jarvinen@helsinki.fi> <20070416134818.GA15915@infradead.org> <Pine.LNX.4.64.0704161703170.28337@kivilampi-30.cs.helsinki.fi> <46238B13.5070201@trash.net> <Pine.LNX.4.64.0704161758020.28337@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Hellwig <hch@infradead.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: =?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42901 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030763AbXDPPcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 11:32:08 -0400
In-Reply-To: <Pine.LNX.4.64.0704161758020.28337@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ilpo J=E4rvinen wrote:
> On Mon, 16 Apr 2007, Patrick McHardy wrote:
>=20
>>[...]
>=20
> ...in the other (original) patch description that is not copied fully=
 here=20
> I had a sort of disclaimer for these missing ones but in case they sh=
ould=20
> all be changed so that if the added tcp_sock is the only local variab=
le I=20
> can do that of course... It's not clear to me what is really the pref=
erred=20
> style considering all the variants... E.g., tcp_check_probe_timer (be=
low)=20
> does not have the newline before this patch either?!? :-) ...tried to=
 look=20
> from CodingStyle too but it didn't give any light to this thing...


The preferred style is a newline after variable declarations. Some
(mostly old) code doesn't consistently do that, but in cases where
you add the first local variable you should really add them.

>>> 	const struct inet_connection_sock *icsk =3D inet_csk(sk);
>=20
>=20
> ...No newline should be place here, since it's being followed by=20
> another local variable defination.


Yes, this one was a mistake. In this case I would probably leave it
as it was before to avoid bloating the patch, but I guess nobody
would mind if you'd add newlines here as well, the patch is not very
large or hard to understand anyway.

