From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25] [TCP]: Correct DSACK check placing
Date: Fri, 16 Nov 2007 16:18:19 -0800 (PST)
Message-ID: <20071116.161819.129445814.davem@davemloft.net>
References: <Pine.LNX.4.64.0711161724050.24866@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35546
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762375AbXKQASY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Nov 2007 19:18:24 -0500
In-Reply-To: <Pine.LNX.4.64.0711161724050.24866@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri, 16 Nov 2007 17:29:46 +0200 (EET)

> Previously one of the in-block skip branches was missing it.
>=20
> Also, drop it from tail-fully-processed case because the next
> iteration will do exactly the same thing, i.e., process the
> SACK block that contains the DSACK information.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied, thanks Ilpo.
