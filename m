From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Re: still having r8169 woes with XID 18000000
Date: Sat, 05 Jun 2010 02:02:34 -0700 (PDT)
Message-ID: <20100605.020234.15253307.davem@davemloft.net>
References: <4C09387F.1050403@iki.fi>
	<4C09611B.2090805@iki.fi>
	<4C09FF4B.4050601@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: phil@nwl.cc, romieu@fr.zoreil.com, netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35788
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932555Ab0FEJCZ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Jun 2010 05:02:25 -0400
In-Reply-To: <4C09FF4B.4050601@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Sat, 05 Jun 2010 10:39:55 +0300

> Ok, I compared Realtek's and the in-tree driver. The only essential
> difference is that Realtek driver uses udelay(100) in mdio_write()'s
> busy polling loop where as the in-tree uses udelay(25). And that seem=
s
> to be the magic difference! Using udelay(100) fixes this!
>=20
> I'm guessing that the phy needs slight delay between consecutive
> mdio_write's even if it has advertised that the write has been
> completed. And yes, just adding a small delay in the end of mdio_writ=
e
> does seem to work too.
>=20
> Francois, you think the below patch is ok? Should I send it as proper=
ly
> formatted commit?

Excellent detective work, Francois please review!
