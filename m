From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: make usbnet_get_link() fall back to
 ethtool_op_get_link()
Date: Sun, 01 Mar 2009 20:45:48 -0800 (PST)
Message-ID: <20090301.204548.152840730.davem@davemloft.net>
References: <87y6vti0a1.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46148
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754259AbZCBEqG convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Mar 2009 23:46:06 -0500
In-Reply-To: <87y6vti0a1.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Thu, 26 Feb 2009 18:19:18 +0100

> Make usbnet_get_link() fall back to ethtool_op_get_link() instead of
> defaulting to 1. =20
>     =20
> This makes usbnet_get_link return valid results without the need for =
a
> driver specific check_connect or mii ops as long as the driver calls
> netif_carrier_{on,off}() as appropriate.  cdc_ether is an example of
> such a driver.
>=20
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>

Applied, thanks.
