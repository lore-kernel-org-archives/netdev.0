From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ks8842: Add module param for setting mac address
Date: Sun, 18 Apr 2010 21:18:00 -0700 (PDT)
Message-ID: <20100418.211800.112605815.davem@davemloft.net>
References: <1271611557.24099.11.camel@debian>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: richard.rojfors@pelagicore.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49991
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750766Ab0DSER5 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Apr 2010 00:17:57 -0400
In-Reply-To: <1271611557.24099.11.camel@debian>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Richard R=F6jfors <richard.rojfors@pelagicore.com>
Date: Sun, 18 Apr 2010 19:25:57 +0200

> This patch adds a module parameter for setting the MAC address.
>=20
> To ensure this MAC address is used, the MAC address is written
> after each hardware reset.
>=20
> Signed-off-by: Richard R=F6jfors <richard.rojfors@pelagicore.com>

Your driver isn't unique, or special, and it doesn't need
to do special things to handle this situation.

Either probe the information from somewhere, or use a random
MAC address.

I'm not applying this.
