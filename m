From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [TCP]: Bind fackets_out state to highest_sack more
 tightly
Date: Mon, 10 Dec 2007 04:31:27 -0800 (PST)
Message-ID: <20071210.043127.60066660.davem@davemloft.net>
References: <Pine.LNX.4.64.0712101426010.18529@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41547
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753737AbXLJMb2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Dec 2007 07:31:28 -0500
In-Reply-To: <Pine.LNX.4.64.0712101426010.18529@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 10 Dec 2007 14:27:24 +0200 (EET)

> Added checks will catch most of the errors if the current
> complex fack_count counting logic is flawed somewhere.
>=20
> Fackets_out should always be advancable if highest_sack is too
> because the fackets_out is nowadays accurate (and obviously it
> must be smaller than packets_out).
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied to net-2.6.25, thanks!
