From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] WAN: Fix a TX IRQ causing BUG() in PC300 and PCI200SYN
 drivers.
Date: Sun, 12 Dec 2010 15:03:36 -0800 (PST)
Message-ID: <20101212.150336.229742406.davem@davemloft.net>
References: <m37hfe7iiw.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41885
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751351Ab0LLXDI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Dec 2010 18:03:08 -0500
In-Reply-To: <m37hfe7iiw.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Halasa <khc@pm.waw.pl>
Date: Sun, 12 Dec 2010 23:06:47 +0100

> We must not wake the TX queue without free TX descriptors.
> sca_xmit() expects at least one free descriptor and BUGs otherwise.
>=20
> Problem reported and fix tested by Bernie Innocenti and Ward Vandeweg=
e.
>=20
> Signed-off-by: Krzysztof Ha=A9=A9asa <khc@pm.waw.pl>

Applied.
