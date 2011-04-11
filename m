From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: r8169: convert to hw_features
Date: Sun, 10 Apr 2011 18:55:56 -0700 (PDT)
Message-ID: <20110410.185556.260087177.davem@davemloft.net>
References: <1302277067.19764.2.camel@obelisk.thedillows.org>
	<20110408163556.D8D1213909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com, dave@thedillows.org
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42671
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752493Ab1DKB4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Apr 2011 21:56:33 -0400
In-Reply-To: <20110408163556.D8D1213909@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Fri,  8 Apr 2011 18:35:56 +0200 (CEST)

> Simple conversion with a bit of needed cleanup.
>=20
> This also fixes:
>  - confusion around vlan_features in rtl8169_vlan_mode(),
>  - problem with broken TSO for too big MTU (the limit is set
>    at 0xFFF --- max MSS field value).
>=20
> SG+IP_CSUM+TSO is left disabled by default, based on suggestion by
> David Dillow.
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied.
