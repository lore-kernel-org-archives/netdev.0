From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] [TCP] MIB: Add counters for discarded SACK blocks
Date: Fri, 24 Aug 2007 22:56:08 -0700 (PDT)
Message-ID: <20070824.225608.93637672.davem@davemloft.net>
References: <118761579328-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11876157932029-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1187615793520-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48709
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757248AbXHYF4J convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Aug 2007 01:56:09 -0400
In-Reply-To: <1187615793520-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 20 Aug 2007 16:16:33 +0300

> In DSACK case, some events are not extraordinary, such as packet
> duplication generated DSACK. They can arrive easily below
> snd_una when undo_marker is not set (TCP being in CA_Open),
> counting such DSACKs amoung SACK discards will likely just
> mislead if they occur in some scenario when there are other
> problems as well. Similarly, excessively delayed packets could
> cause "normal" DSACKs. Therefore, separate counters are
> allocated for DSACK events.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Also applied, thanks a lot!
