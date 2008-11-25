From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 06/10] tcp: Try to restore large SKBs while SACK
 processing
Date: Mon, 24 Nov 2008 21:20:46 -0800 (PST)
Message-ID: <20081124.212046.118565466.davem@davemloft.net>
References: <1227536527-29713-5-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1227536527-29713-6-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1227536527-29713-7-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48138
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750838AbYKYFUr convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2008 00:20:47 -0500
In-Reply-To: <1227536527-29713-7-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 24 Nov 2008 16:22:03 +0200

> During SACK processing, most of the benefits of TSO are eaten by
> the SACK blocks that one-by-one fragment SKBs to MSS sized chunks.
> Then we're in problems when cleanup work for them has to be done
> when a large cumulative ACK comes. Try to return back to pre-split
> state already while more and more SACK info gets discovered by
> combining newly discovered SACK areas with the previous skb if
> that's SACKed as well.
 ...
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Really nice work, patch applied, thanks!
