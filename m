From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] WAN: flush tx_queue in hdlc_ppp to prevent panic on
 rmmod hw_driver.
Date: Fri, 16 Apr 2010 15:41:17 -0700 (PDT)
Message-ID: <20100416.154117.164075021.davem@davemloft.net>
References: <m3mxx5mv8v.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36972
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932710Ab0DPWlP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 18:41:15 -0400
In-Reply-To: <m3mxx5mv8v.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Halasa <khc@pm.waw.pl>
Date: Thu, 15 Apr 2010 02:09:52 +0200

> tx_queue is used as a temporary queue when not allowed to queue skb
> directly to the hw device driver (which may sleep). Most paths flush
> it before returning, but ppp_start() currently cannot. Make sure we
> don't leave skbs pointing to a non-existent device.
>=20
> Thanks to Michael Barkowski for reporting this problem.
>=20
> Signed-off-by: Krzysztof Ha=A9=A9asa <khc@pm.waw.pl>

Applied, thank you.
