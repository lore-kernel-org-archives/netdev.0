From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCHv5 3/5] [TCP]: Reworked recovery's TCPCB_LOST
 marking functions
Date: Sat, 24 Mar 2007 21:09:14 -0700 (PDT)
Message-ID: <20070324.210914.85409551.davem@davemloft.net>
References: <11740704662337-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11740704663404-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1174070466450-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59896
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965051AbXCYEJP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Mar 2007 00:09:15 -0400
In-Reply-To: <1174070466450-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri, 16 Mar 2007 20:41:04 +0200

> Complete rewrite for update_scoreboard and mark_head_lost. Couple
> of hints became unnecessary because of this change, NewReno code
> was greatly simplified. I changed !TCPCB_TAGBITS check from the
> original to a !(S|L) check but it shouldn't make a difference,
> and if there ever is a R only skb TCP will mark it as LOST too
> that is a correct behavior (IMHO). The algorithm uses some ideas
> presented by David Miller and Baruch Even.
>=20
> This patch provides an unoptimized version.
>=20
> Seqno lookups require fast lookups that are provided using
> RB-tree patch (which is nowadays included into the latest
> net-2.6.22).
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Ok, sorry it took so long to review this, but it looks like it
will work, patch applied.

Thanks!
