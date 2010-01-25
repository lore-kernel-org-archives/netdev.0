From: Kristoffer Glembo <kristoffer@gaisler.com>
Subject: Re: [PATCH 1/1 V3] net: Add Aeroflex Gaisler 10/100/1G Ethernet MAC
 driver
Date: Mon, 25 Jan 2010 11:54:55 +0100
Message-ID: <4B5D787F.2040003@gaisler.com>
References: <1264164677-6397-1-git-send-email-kristoffer@gaisler.com>	<1264164677-6397-2-git-send-email-kristoffer@gaisler.com> <20100123.020549.147260506.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-7
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail175c2.megamailservers.com ([69.49.111.75]:48687 "EHLO
	mail175c2.megamailservers.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753540Ab0AYK6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 05:58:40 -0500
In-Reply-To: <20100123.020549.147260506.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
>=20
> Generates build warnings, please fix:
>=20
> drivers/net/greth.c: In function =A1greth_rx=A2:
> drivers/net/greth.c:781: warning: passing argument 1 of =A1greth_prin=
t_rx_packet=A2 makes integer from pointer without a cast
> drivers/net/greth.c: In function =A1greth_rx_gbit=A2:
> drivers/net/greth.c:885: warning: passing argument 1 of =A1greth_prin=
t_rx_packet=A2 makes integer from pointer without a cast
>=20
> phys_to_virt() give a virtual address pointer, so this should
> have generated warnings on 64-bit as well as 32-bit systems.
>=20
> I can't see how you could have possibly build tested this and
> not seen the warnings.


After removing the #defines that guarded those calls I only built it as=
 part of the
whole kernel and forgot to check for any warnings. Sorry!

I'll resend ...

/Kristoffer
