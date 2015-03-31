From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: smc91x: Remove an unused variable
Date: Tue, 31 Mar 2015 10:53:28 -0400 (EDT)
Message-ID: <20150331.105328.2195438658331769456.davem@davemloft.net>
References: <1427733818-11823-1-git-send-email-festevam@gmail.com>
	<20150330172057.GG17728@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: festevam@gmail.com, netdev@vger.kernel.org,
	fabio.estevam@freescale.com
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47098 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754198AbbCaOxa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 10:53:30 -0400
In-Reply-To: <20150330172057.GG17728@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
Date: Mon, 30 Mar 2015 19:20:57 +0200

> On Mon, Mar 30, 2015 at 01:43:38PM -0300, Fabio Estevam wrote:
>> From: Fabio Estevam <fabio.estevam@freescale.com>
>>=20
>> Commit cb6e0b3690f48dff ("net: smc91x: make use of 4th parameter to =
devm_gpiod_get_index")
>> caused the following build warning:
>>=20
>> drivers/net/ethernet/smsc/smc91x.c:2208:6: warning: unused variable =
'res' [-Wunused-variable]
>>=20
>> Remove the unused 'res' variable.
>>=20
>> Reported-by: Olof's autobuilder <build@lixom.net>
>> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
> I wonder why I didn't notice this because the 0day build robot tested=
 my
> tree and didn't report this warning. Probably that means this driver
> wasn't tested.

This driver can't be enabled on x86/x86-64 so the build testing it will
get is going to be extremely limited.
