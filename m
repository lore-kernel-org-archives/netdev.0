From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [TCP] FRTO: work-around inorder receivers
Date: Tue, 13 May 2008 02:54:38 -0700 (PDT)
Message-ID: <20080513.025438.138680529.davem@davemloft.net>
References: <1210671834-15406-1-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1210671834-15406-2-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, damon@damtek.com
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59758
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750740AbYEMJyo convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 05:54:44 -0400
In-Reply-To: <1210671834-15406-2-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 13 May 2008 12:43:54 +0300

> If receiver consumes segments successfully only in-order, FRTO
> fallback to conventional recovery produces RTO loop because
> FRTO's forward transmissions will always get dropped and need to
> be resent, yet by default they're not marked as lost (which are
> the only segments we will retransmit in CA_Loss).
>=20
> Price to pay about this is occassionally unnecessarily
> retransmitting the forward transmission(s). SACK blocks help
> a bit to avoid this, so it's mainly a concern for NewReno case
> though SACK is not fully immune either.
>=20
> This change has a side-effect of fixing SACKFRTO problem where
> it didn't have snd_nxt of the RTO time available anymore when
> fallback become necessary (this problem would have only occured
> when RTO would occur for two or more segments and ECE arrives
> in step 3; no need to figure out how to fix that unless the
> TODO item of selective behavior is considered in future).
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
> Reported-by: Damon L. Chesser <damon@damtek.com>
> Tested-by: Damon L. Chesser <damon@damtek.com>

Also applied, thanks!
