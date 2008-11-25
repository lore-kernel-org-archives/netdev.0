From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 05/10] tcp: make tcp_sacktag_one able to handle partial
 skb too
Date: Mon, 24 Nov 2008 21:15:24 -0800 (PST)
Message-ID: <20081124.211524.133482462.davem@davemloft.net>
References: <1227536527-29713-4-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1227536527-29713-5-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1227536527-29713-6-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42882
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750745AbYKYFPY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2008 00:15:24 -0500
In-Reply-To: <1227536527-29713-6-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 24 Nov 2008 16:22:02 +0200

> This is preparatory work for SACK combiner patch which may
> have to count TCP state changes for only a part of the skb
> because it will intentionally avoids splitting skb to SACKed
> and not sacked parts.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.

Although we need desperately to simplify this function at
some point.  Anything past 6 arguments and you're going onto
the stack on just about every cpu.
