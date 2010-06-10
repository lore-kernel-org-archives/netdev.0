From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: fix mdio_read and update mdio_write according
 to hw specs
Date: Wed, 09 Jun 2010 17:32:19 -0700 (PDT)
Message-ID: <20100609.173219.39173328.davem@davemloft.net>
References: <BD599B881C1D407DA7BC93A9244650B0@realtek.com.tw>
	<1276060930-15697-1-git-send-email-timo.teras@iki.fi>
	<20100609061825.GA7087@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: timo.teras@iki.fi, netdev@vger.kernel.org, hayeswang@realtek.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57111
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756410Ab0FJAcI convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jun 2010 20:32:08 -0400
In-Reply-To: <20100609061825.GA7087@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Francois Romieu <romieu@fr.zoreil.com>
Date: Wed, 9 Jun 2010 08:18:25 +0200

> Timo Ter=E4s <timo.teras@iki.fi> :
>> Realtek confirmed that a 20us delay is needed after mdio_read and
>> mdio_write operations. Reduce the delay in mdio_write, and add it
>> to mdio_read too. Also add a comment that the 20us is from hw specs.
>>=20
>> Signed-off-by: Timo Ter=E4s <timo.teras@iki.fi>
>=20
> Acked-off-by: Francois Romieu <romieu@fr.zoreil.com>

I think you meant "Acked-by: " :-)  I fixed this and committed
Timo's patch, thanks everyone!
