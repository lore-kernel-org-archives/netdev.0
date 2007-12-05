From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] [TCP] FRTO: Use of existing funcs make code more
 obvious & robust
Date: Wed, 05 Dec 2007 02:21:05 -0800 (PST)
Message-ID: <20071205.022105.202367755.davem@davemloft.net>
References: <11967869303114-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11967869303567-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52505
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751372AbXLEKVG convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2007 05:21:06 -0500
In-Reply-To: <11967869303567-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue,  4 Dec 2007 18:48:48 +0200

> Though there's little need for everything that tcp_may_send_now
> does (actually, even the state had to be adjusted to pass some
> checks FRTO does not want to occur), it's more robust to let it
> make the decision if sending is allowed. State adjustments
> needed:
> - Make sure snd_cwnd limit is not hit in there
> - Disable nagle (if necessary) through the frto_counter =3D=3D 2
>=20
> The result of check for frto_counter in argument to call for
> tcp_enter_frto_loss can just be open coded, therefore there
> isn't need to store the previous frto_counter past
> tcp_may_send_now.
>=20
> In addition, returns can then be combined.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
