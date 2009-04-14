From: David Miller <davem@davemloft.net>
Subject: Re: initial congestion window for connections in the listen queue
Date: Tue, 14 Apr 2009 02:09:18 -0700 (PDT)
Message-ID: <20090414.020918.161736461.davem@davemloft.net>
References: <Pine.LNX.4.64.0904140051100.9234@wrl-59.cs.helsinki.fi>
	<20090413.145829.97306950.davem@davemloft.net>
	<Pine.LNX.4.64.0904141118260.10088@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: opurdila@ixiacom.com, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49883
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751154AbZDNJJ0 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2009 05:09:26 -0400
In-Reply-To: <Pine.LNX.4.64.0904141118260.10088@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 14 Apr 2009 11:37:08 +0300 (EEST)

> [PATCH] tcp: fix >2 iw selection
>=20
> A long-standing feature in tcp_init_metrics() is such that
> any of its goto reset prevents call to tcp_init_cwnd().
>=20
> Compile tested.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Looks good, applied, thanks!
