From: Frank Li <lznuaa@gmail.com>
Subject: Re: NET: FEC: dynamtic check DMA desc buff type
Date: Mon, 4 Mar 2013 12:35:10 +0800
Message-ID: <CAHrpEqS_nrBzHr23vQrukQE0XmxP5EVWB44aOcMQctjzYqgnGQ@mail.gmail.com>
References: <513415C1.2070904@uclinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Frank Li <Frank.Li@freescale.com>,
	Sascha Hauer <s.hauer@pengutronix.de>, netdev@vger.kernel.org,
	lkml@vger.kernel.org
To: Greg Ungerer <gerg@uclinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f172.google.com ([74.125.82.172]:60257 "EHLO
	mail-we0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755198Ab3CDEfM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Mar 2013 23:35:12 -0500
In-Reply-To: <513415C1.2070904@uclinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/3/4 Greg Ungerer <gerg@uclinux.org>:
>
> Hi Frank,
>
> Commit ff43da86c69d76a726ffe7d1666148960dc1d108 ("NET: FEC: dynamtic
> check DMA desc buff type") breaks building of the fec ethernet driver
> for non CONFIG_ARCH_MXC targets.
>
> For example building for ColdFire devices with FEC hardware now
> fails like this
>
> drivers/net/ethernet/freescale/fec.c: In function =91fec_enet_get_nex=
tdesc=92:
> drivers/net/ethernet/freescale/fec.c:215:18: error: invalid use of un=
defined
> type =91struct bufdesc_ex=92
> drivers/net/ethernet/freescale/fec.c: In function =91fec_enet_get_pre=
vdesc=92:
> drivers/net/ethernet/freescale/fec.c:224:18: error: invalid use of un=
defined
> type =91struct bufdesc_ex=92
> drivers/net/ethernet/freescale/fec.c: In function =91fec_enet_start_x=
mit=92:
> drivers/net/ethernet/freescale/fec.c:286:37: error: arithmetic on poi=
nter to
> an incomplete type
> drivers/net/ethernet/freescale/fec.c:287:13: error: arithmetic on poi=
nter to
> an incomplete type
> drivers/net/ethernet/freescale/fec.c:324:7: error: dereferencing poin=
ter to
> incomplete type
> etc....
>
> These where generated on 3.9-rc1.
>
> Can you please fix?

I can fix it.
I have not build environment to test.
Can you help me to test it?

>
> Regards
> Greg
>
>  --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
