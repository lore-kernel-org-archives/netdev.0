From: Lennart Schulte <lennart.schulte@nets.rwth-aachen.de>
Subject: Re: [PATCH] tcp: sack lost marking fixes
Date: Thu, 14 Oct 2010 15:36:59 +0200
Message-ID: <4CB7077B.2080007@nets.rwth-aachen.de>
References: <alpine.DEB.2.00.1010141429150.26447@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Yuchung Cheng <ycheng@google.com>
To: =?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-i4.nets.RWTH-Aachen.DE ([137.226.12.21]:43880 "EHLO
	MAIL-i4.nets.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754558Ab0JNNn1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 09:43:27 -0400
In-Reply-To: <alpine.DEB.2.00.1010141429150.26447@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At the moment I don't have any time to spare to look into this since my
master thesis has to be ready in about 2 weeks. Sorry for that!

On 14.10.2010 13:42, Ilpo J=E4rvinen wrote:
> When only fast rexmit should be done, tcp_mark_head_lost marks
> L too far. Also, sacked_upto below 1 is perfectly valid number,
> the packets =3D=3D 0 then needs to be trapped elsewhere.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
> ---
> I think 6830c25b7d08fbbd922959425193791bc42079f2 that added the
> packets =3D=3D 0 check is mostly wrong but I cc'ed Lennart if he has =
some=20
> particular case I'm missing that wouldn't work after this patch.
>=20
> Dave, no particular "bad regression" fixed here, so no absolute need =
to=20
> have this in net-2.6 but I leave it up to you whether there or net-ne=
xt.
>=20
>  ...

