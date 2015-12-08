From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] I.MX6: Fix Ethernet PHY mode on Ventana boards
Date: Tue, 08 Dec 2015 12:24:47 -0500 (EST)
Message-ID: <20151208.122447.863577308058835164.davem@davemloft.net>
References: <m3egeyct8o.fsf@t19.piap.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tharvey@gateworks.com, netdev@vger.kernel.org
To: khalasa@piap.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38438 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002AbbLHRYt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 12:24:49 -0500
In-Reply-To: <m3egeyct8o.fsf@t19.piap.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: khalasa@piap.pl (Krzysztof Ha=A9=A9asa)
Date: Mon, 07 Dec 2015 13:56:23 +0100

> Gateworks Ventana boards seem to need "RGMII-ID" (internal delay)
> PHY mode, instead of simple "RGMII", for their Marvell 88E1510
> transceiver. Otherwise, the Ethernet MAC doesn't work with Marvell PH=
Y
> driver (TX doesn't seem to work correctly).
>=20
> Tested on GW5400 rev. C.
>=20
> This bug affects ARM Fedora 23.
>=20
> Signed-off-by: Krzysztof Ha=A9=A9asa <khalasa@piap.pl>

Since this only touched DT files in the ARM platform code, maybe
the ARM tree is the best path for this patch rather than mine?
