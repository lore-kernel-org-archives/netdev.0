From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] [TCP]: NAGLE_PUSH seems to be a wrong way around
Date: Wed, 05 Dec 2007 02:26:34 -0800 (PST)
Message-ID: <20071205.022634.114614917.davem@davemloft.net>
References: <11967869303567-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11967869303709-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1196786930388-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47369
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751695AbXLEK0f convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2007 05:26:35 -0500
In-Reply-To: <1196786930388-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue,  4 Dec 2007 18:48:50 +0200

> The comment in tcp_nagle_test suggests that. This bug is very
> very old, even 2.4.0 seems to have it.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Wow, I can't believed I missed this during the TSO output
path rewrite.

I will have to double check the history, because I stated
at these conditionals many times during that work and I
wonder if I inverted a "!" somewhere along the line.

Thanks for the fix, applied!
