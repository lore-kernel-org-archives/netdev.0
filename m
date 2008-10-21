From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: should use number of sack blocks instead of -1
Date: Tue, 21 Oct 2008 16:29:20 -0700 (PDT)
Message-ID: <20081021.162920.219684361.davem@davemloft.net>
References: <Pine.LNX.4.64.0810211153300.7072@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58446
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752021AbYJUX3n convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Oct 2008 19:29:43 -0400
In-Reply-To: <Pine.LNX.4.64.0810211153300.7072@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 21 Oct 2008 11:58:05 +0300 (EEST)

> While looking for the recent "sack issue" I also read all eff_sacks
> usage that was played around by some relevant commit. I found
> out that there's another thing that is asking for a fix (unrelated
> to the "sack issue" though).
>=20
> This feature has probably very little significance in practice.
> Opposite direction timeout with bidirectional tcp comes to me as
> the most likely scenario though there might be other cases as
> well related to non-data segments we send (e.g., response to the
> opposite direction segment). Also some ACK losses or option space
> wasted for other purposes is necessary to prevent the earlier
> SACK feedback getting to the sender.
=2E..
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied, thanks Ilpo.
