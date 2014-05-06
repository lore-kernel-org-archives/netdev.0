From: Brian Lilly <brian@crystalfontz.com>
Subject: i.MX28 based system losing eth0 on boot
Date: Tue, 6 May 2014 09:44:34 -0700
Message-ID: <CAOk88BLR=nwNGdT++39vLdOt=TwZmemF-trSQPY8AdMN9tKtKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Jim Baxter <jim_baxter@mentor.com>,
	Frank Li <Frank.Li@freescale.com>,
	Fugang Duan <B38611@freescale.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: =?UTF-8?Q?Uwe_Kleine=2DK=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:42272 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750821AbaEFQpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 12:45:15 -0400
Received: by mail-ob0-f178.google.com with SMTP id va2so7308357obc.9
        for <netdev@vger.kernel.org>; Tue, 06 May 2014 09:45:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Uwe:

With commit a264b981f2c76e281ef27e7232774bf6c54ec865 we're having eth0
come up, then brought right back down with an MDIO rx timeout moments
after.  Adding back in the removed code keeps the interface alive and
it's working afterward without trouble.  I've tested the re-inserted
code in 3.12, 3.14 without issue on our boards.

Is there something else that can be done to prevent the MDIO timeouts?
We are using basically the same schematic for networking as the
imx28evk.

Any thoughts on how to resolve this?

Thanks,
Brian Lilly
