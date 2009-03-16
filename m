From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/7] tcp: make sure xmit goal size never becomes zero
Date: Sun, 15 Mar 2009 20:11:23 -0700 (PDT)
Message-ID: <20090315.201123.177187129.davem@davemloft.net>
References: <12370756751028-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12370756752721-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12370756754020-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, zbr@ioremap.net, mingo@elte.hu
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39278
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751205AbZCPDLg convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Mar 2009 23:11:36 -0400
In-Reply-To: <12370756754020-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sun, 15 Mar 2009 02:07:55 +0200

> It's not too likely to happen, would basically require crafted
> packets (must hit the max guard in tcp_bound_to_half_wnd()).
> It seems that nothing that bad would happen as there's tcp_mems
> and congestion window that prevent runaway at some point from
> hurting all too much (I'm not that sure what all those zero
> sized segments we would generate do though in write queue).
> Preventing it regardless is certainly the best way to go.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
