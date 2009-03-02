From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 14/17] tcp: remove pointless .dsack code
Date: Mon, 02 Mar 2009 03:03:20 -0800 (PST)
Message-ID: <20090302.030320.95493086.davem@davemloft.net>
References: <12358322831599-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322832879-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322831019-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59075
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757389AbZCBLDi convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 06:03:38 -0500
In-Reply-To: <12358322831019-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 28 Feb 2009 16:44:39 +0200

> From: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
>=20
> In the pure assignment case, the earlier zeroing is
> still in effect.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

I skipped this one.

These tests could be there to avoid dirtying a cacheline
when unnecessary.  And so unless we can prove the condition
always hits and we always do the write, we should keep
the tests there.
