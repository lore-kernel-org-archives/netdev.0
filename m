From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 RESEND 2/9] ethtool: enable GSO and GRO by default
Date: Sun, 13 Feb 2011 10:50:23 -0800 (PST)
Message-ID: <20110213.105023.68138742.davem@davemloft.net>
References: <cover.1297594674.git.mirq-linux@rere.qmqm.pl>
	<66135e57d38599c0dfce347643858558c4f026c4.1297594674.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39051
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754606Ab1BMStr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Feb 2011 13:49:47 -0500
In-Reply-To: <66135e57d38599c0dfce347643858558c4f026c4.1297594674.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Sun, 13 Feb 2011 12:11:45 +0100 (CET)

>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

This is not appropriate.

Now, every driver that lacks SG support will spit out that warning
message in netdev_fix_features().

That's why the check is there conditionalizing NETIF_F_GSO on
NETIF_F_SG in register_netdevice().
