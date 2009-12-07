From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: dst_release() cleanup
Date: Mon, 07 Dec 2009 20:13:14 +0100
Message-ID: <4B1D53CA.3060004@gmail.com>
References: <4B1A4BC5.3050300@gmail.com> <20091207091746.51d8958a@nehalam> <alpine.DEB.2.00.0912072056350.27565@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:51368 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757879AbZLGTNl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 14:13:41 -0500
In-Reply-To: <alpine.DEB.2.00.0912072056350.27565@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen a =E9crit :

> That's their problem then to fix all relevant places. ...That won't e=
ven=20
> compile because of constructs like this:
>=20
> 	if (WARN_ON(x))
>=20
> ...To my knowing this perfectly legal way of doing this.
>=20

Sure, but let be conservative :)


