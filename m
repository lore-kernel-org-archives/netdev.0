From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] [TCP]: Discard fuzzy SACK blocks
Date: Fri, 24 Aug 2007 22:55:29 -0700 (PDT)
Message-ID: <20070824.225529.43496742.davem@davemloft.net>
References: <1187615793583-git-send-email-ilpo.jarvinen@helsinki.fi>
	<118761579328-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11876157932029-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48706
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757267AbXHYFza convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Aug 2007 01:55:30 -0400
In-Reply-To: <11876157932029-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 20 Aug 2007 16:16:32 +0300

> SACK processing code has been a sort of russian roulette as no
> validation of SACK blocks is previously attempted. Besides, it
> is not very clear what all kinds of broken SACK blocks really
> mean (e.g., one that has start and end sequence numbers
> reversed). So now close the roulette once and for all.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Thanks a lot for coding this up, I like it a lot, applied.

I have some minor worries about the D-SACK lower bound, but
it's probably OK and I'm just being paranoid :-)
