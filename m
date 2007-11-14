From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [TCP] FRTO: Limit snd_cwnd if TCP was application
 limited
Date: Tue, 13 Nov 2007 21:02:33 -0800 (PST)
Message-ID: <20071113.210233.42884295.davem@davemloft.net>
References: <Pine.LNX.4.64.0711140004210.3997@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34376
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750727AbXKNFCe convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 00:02:34 -0500
In-Reply-To: <Pine.LNX.4.64.0711140004210.3997@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Wed, 14 Nov 2007 00:08:18 +0200 (EET)

>=20
> Otherwise TCP might violate packet ordering principles that FRTO
> is based on. If conventional recovery path is chosen, this won't
> be significant at all. In practice, any small enough value will
> be sufficient to provide proper operation for FRTO, yet other
> users of snd_cwnd might benefit from a "close enough" value.
>=20
> FRTO's formula is now equal to what tcp_enter_cwr() uses.
>=20
> FRTO used to check application limitedness a bit differently but
> I changed that in commit 575ee7140dabe9b9c4f66f4f867039b97e548867
> and as a result checking for application limitedness became
> completely non-existing.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied to net-2.6, thanks Ilpo.
