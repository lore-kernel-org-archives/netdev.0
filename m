From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] tcp: miscounts due to tcp_fragment pcount reset
Date: Thu, 02 Apr 2009 16:32:35 -0700 (PDT)
Message-ID: <20090402.163235.153382360.davem@davemloft.net>
References: <Pine.LNX.4.64.0904011352470.30150@wrl-59.cs.helsinki.fi>
	<Pine.LNX.4.64.0904021212310.30150@wrl-59.cs.helsinki.fi>
	<Pine.LNX.4.64.0904021216170.30150@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: markus@trippelsdorf.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, uwe.bugla@gmx.de
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54624
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762623AbZDBXcq convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Apr 2009 19:32:46 -0400
In-Reply-To: <Pine.LNX.4.64.0904021216170.30150@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 2 Apr 2009 12:18:20 +0300 (EEST)

>=20
> It seems that trivial reset of pcount to one was not sufficient
> in tcp_retransmit_skb. Multiple counters experience a positive
> miscount when skb's pcount gets lowered without the necessary
> adjustments (depending on skb's sacked bits which exactly), at
> worst a packets_out miscount can crash at RTO if the write queue
> is empty!
>=20
> Triggering this requires mss change, so bidir tcp or mtu probe or
> like.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
> Reported-by: Markus Trippelsdorf <markus@trippelsdorf.de>
> Tested-by: Uwe Bugla <uwe.bugla@gmx.de>

Applied.
