From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] drivers/net/fec: Fix dual MAC support on i.MX28
Date: Tue, 22 Mar 2011 01:07:17 -0700 (PDT)
Message-ID: <20110322.010717.241446116.davem@davemloft.net>
References: <e8566dc34c4fd544ac630cf7908e4fb613e3ec1a.1300724245.git.LW@KARO-electronics.de>
	<20110322072832.GD28098@S2100-06.ap.freescale.net>
	<19848.22512.18596.3017@ipc1.ka-ro>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shawn.guo@freescale.com, netdev@vger.kernel.org,
	u.kleine-koenig@pengutronix.de
To: LW@KARO-electronics.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58189
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754386Ab1CVIGj convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2011 04:06:39 -0400
In-Reply-To: <19848.22512.18596.3017@ipc1.ka-ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Lothar Wa=DFmann <LW@KARO-electronics.de>
Date: Tue, 22 Mar 2011 09:04:00 +0100

> Shawn Guo writes:
>> > +static int dual_mac;
>> > +module_param(dual_mac, int, S_IRUGO);
>> > +
>>=20
>> As you are detecting dual_mac in probe function, is this necessary?
>>=20
> Not really. I added this is only for debugging.

Please do not add driver-specific module parameters.
