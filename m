From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 15/17] tcp: kill pointless if () in sack_remove
Date: Mon, 02 Mar 2009 03:03:47 -0800 (PST)
Message-ID: <20090302.030347.216947448.davem@davemloft.net>
References: <12358322832879-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322831019-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322831223-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59078
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757393AbZCBLEF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 06:04:05 -0500
In-Reply-To: <12358322831223-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 28 Feb 2009 16:44:40 +0200

> From: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

I skipped this for the same reason I skipped patch #14.
This could be there to avoid dirtying that part of
the structure when it isn't necessary.
