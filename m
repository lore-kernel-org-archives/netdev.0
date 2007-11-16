From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/10] [TCP]: Extend reordering detection to cover
 CA_Loss partially
Date: Thu, 15 Nov 2007 19:35:27 -0800 (PST)
Message-ID: <20071115.193527.149970561.davem@davemloft.net>
References: <11951338542267-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1195133854795-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11951338543953-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52094
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753629AbXKPDf2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 22:35:28 -0500
In-Reply-To: <11951338543953-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 15 Nov 2007 15:37:26 +0200

> This implements more accurately what is stated in sacktag's
> overall comment:
>=20
>   "Both of these heuristics are not used in Loss state, when
>    we cannot account for retransmits accurately."
>=20
> When CA_Loss state is entered, the state changer ensures that
> undo_marker is only set if no TCPCB_RETRANS skbs were found,
> thus having non-zero undo_marker in CA_Loss basically tells
> that the R-bits still accurately reflect the current state
> of TCP.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied to net-2.6.25, thanks!
