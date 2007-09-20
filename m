From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/9] [TCP]: Move accounting from tso_acked to
 clean_rtx_queue
Date: Thu, 20 Sep 2007 11:33:05 -0700 (PDT)
Message-ID: <20070920.113305.27448062.davem@davemloft.net>
References: <11902906723619-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11902906723822-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1190290672770-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57170
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750758AbXITSdF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 14:33:05 -0400
In-Reply-To: <1190290672770-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 20 Sep 2007 15:17:47 +0300

> The accounting code is pretty much the same, so it's a shame
> we do it in two places.
>=20
> I'm not too sure if added fully_acked check in MTU probing is
> really what we want perhaps the added end_seq could be used in
> the after() comparison.

Indeed there are a bunch of tradeoffs to consider when
handling the TSO-partial-ack cases.

> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied, thanks Ilpo.
