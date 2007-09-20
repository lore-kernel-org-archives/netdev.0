From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/9] [TCP]: Maintain highest_sack accurately to the
 highest skb
Date: Thu, 20 Sep 2007 11:29:12 -0700 (PDT)
Message-ID: <20070920.112912.04442227.davem@davemloft.net>
References: <11902906724088-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11902906721846-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57160
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752042AbXITS3M convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 14:29:12 -0400
In-Reply-To: <11902906721846-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 20 Sep 2007 15:17:44 +0300

> In general, it should not be necessary to call tcp_fragment for
> already SACKed skbs, but it's better to be safe than sorry. And
> indeed, it can be called from sacktag when a DSACK arrives or
> some ACK (with SACK) reordering occurs (sacktag could be made
> to avoid the call in the latter case though I'm not sure if it's
> worth of the trouble and added complexity to cover such marginal
> case).
>=20
> The collapse case has return for SACKED_ACKED case earlier, so
> just WARN_ON if internal inconsistency is detected for some
> reason.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied, thanks Ilpo.
