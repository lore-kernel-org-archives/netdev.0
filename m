From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 12/17] tcp: add helper for AI algorithm
Date: Mon, 02 Mar 2009 03:02:33 -0800 (PST)
Message-ID: <20090302.030233.137232761.davem@davemloft.net>
References: <12358322834113-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1235832283214-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322831599-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59069
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754761AbZCBLCw convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 06:02:52 -0500
In-Reply-To: <12358322831599-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 28 Feb 2009 16:44:37 +0200

> From: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
>=20
> It seems that implementation in yeah was inconsistent to what
> other did as it would increase cwnd one ack earlier than the
> others do.
>=20
> Size benefits:
>=20
>   bictcp_cong_avoid |  -36
>   tcp_cong_avoid_ai |  +52
>   bictcp_cong_avoid |  -34
>   tcp_scalable_cong_avoid |  -36
>   tcp_veno_cong_avoid |  -12
>   tcp_yeah_cong_avoid |  -38
>=20
> =3D -104 bytes total
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied, nice work.
