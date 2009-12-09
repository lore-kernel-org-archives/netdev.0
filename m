From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: dst_release() cleanup
Date: Wed, 09 Dec 2009 22:46:32 +0100
Message-ID: <4B201AB8.3090904@gmail.com>
References: <20091207091746.51d8958a@nehalam>	<alpine.DEB.2.00.0912072056350.27565@melkinpaasi.cs.helsinki.fi>	<4B1D53CA.3060004@gmail.com> <20091208.203503.45117329.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52427 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756054AbZLIVqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 16:46:34 -0500
In-Reply-To: <20091208.203503.45117329.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 09/12/2009 05:35, David Miller a =C3=A9crit :
>=20
> Using side effects in a debugging macro, that's always asking for
> trouble.  Every time I see this thing I'm going to do a double
> take on it.
>=20
> We can pull the return value into an 'int' with a descriptive name
> such as "orig_dst_refcnt", and also use WARN() to make a descriptive
> error message for kerneloops.org to log if it triggers.
>=20
> Ok Eric?

Sure, I'll submit this when net-next-2.6 reopens :)
