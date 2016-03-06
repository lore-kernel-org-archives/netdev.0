From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH RESEND] net:fec:Fix error checking in the function
 fec_enet_init
Date: Sun, 6 Mar 2016 12:09:44 +0100
Message-ID: <20160306110944.GZ20323@pengutronix.de>
References: <1457121614-9360-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, B38611@freescale.com, andrew@lunn.ch,
	fabio.estevam@freescale.com, l.stach@pengutronix.de,
	rmk+kernel@arm.linux.org.uk, tremyfr@gmail.com,
	johannes@sipsolutions.net, haokexin@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:56432 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751203AbcCFLKB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2016 06:10:01 -0500
Content-Disposition: inline
In-Reply-To: <1457121614-9360-1-git-send-email-xerofoify@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Nicholas,

On Fri, Mar 04, 2016 at 03:00:14PM -0500, Nicholas Krause wrote:
> This fixes error checking in the function fec_enet_init to properly
> check if the internal call to the function fec_enet_alloc_queue fails
> and if so immediately return the error code to the caller for it to
> handle it's own intended error paths.
>=20
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>

Looks right. There seem to be some more oportunities for similar
patches. E.g. if dmam_alloc_coherent fails the effects of
fec_enet_alloc_queue should be undone.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
