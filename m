From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 17/17] tcp: get rid of two unnecessary u16s in
 TCP skb flags copying
Date: Mon, 02 Mar 2009 03:03:57 -0800 (PST)
Message-ID: <20090302.030357.259818988.davem@davemloft.net>
References: <12358322831223-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322833023-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322832837-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59084
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757552AbZCBLEP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 06:04:15 -0500
In-Reply-To: <12358322832837-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 28 Feb 2009 16:44:42 +0200

> From: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
>=20
> I guess these fields were one day 16-bit in the struct but
> nowadays they're just using 8 bits anyway.
>=20
> This is just a precaution, didn't result any change in my
> case but who knows what all those varying gcc versions &
> options do. I've been told that 16-bit is not so nice with
> some cpus.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
