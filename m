From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 14/17] tcp: remove pointless .dsack code
Date: Mon, 02 Mar 2009 03:57:35 -0800 (PST)
Message-ID: <20090302.035735.240266876.davem@davemloft.net>
References: <12358322831019-git-send-email-ilpo.jarvinen@helsinki.fi>
	<20090302.030320.95493086.davem@davemloft.net>
	<Pine.LNX.4.64.0903021340540.31742@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54520
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753358AbZCBL5v convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 06:57:51 -0500
In-Reply-To: <Pine.LNX.4.64.0903021340540.31742@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 2 Mar 2009 13:54:17 +0200 (EET)

> We'll be dirty it anyway (not that I check), the first "real" stateme=
nt
> in tcp_rcv_established is:
>=20
> 	tp->rx_opt.saw_tstamp =3D 0;
>=20
> ...that'll land on the same dword. :-/
>=20
> I suppose the blocks are there just because they had more complexity=20
> inside when they had to calculate the eff_sacks too (maybe it would
> have been better to just remove them in that drop-patch so you would
> have had less head-ache :-)).

That sounds like a good commit log entry for when you resubmit
this patch :-)
