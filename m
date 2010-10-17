From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: sack lost marking fixes
Date: Sun, 17 Oct 2010 13:46:51 -0700 (PDT)
Message-ID: <20101017.134651.189701191.davem@davemloft.net>
References: <alpine.DEB.2.00.1010141429150.26447@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, ycheng@google.com,
	lennart.schulte@nets.rwth-aachen.de
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53800
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932785Ab0JQUq3 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Oct 2010 16:46:29 -0400
In-Reply-To: <alpine.DEB.2.00.1010141429150.26447@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 14 Oct 2010 14:42:30 +0300 (EEST)

> When only fast rexmit should be done, tcp_mark_head_lost marks
> L too far. Also, sacked_upto below 1 is perfectly valid number,
> the packets =3D=3D 0 then needs to be trapped elsewhere.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied to net-next-2.6
