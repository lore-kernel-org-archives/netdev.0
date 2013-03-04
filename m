From: Greg Ungerer <gerg@uclinux.org>
Subject: Re: NET: FEC: dynamtic check DMA desc buff type
Date: Mon, 04 Mar 2013 13:32:17 +1000
Message-ID: <513415C1.2070904@uclinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sascha Hauer <s.hauer@pengutronix.de>, netdev@vger.kernel.org,
	lkml@vger.kernel.org
To: Frank Li <Frank.Li@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-mail04.westnet.com.au ([203.10.1.245]:39633 "EHLO
	outbound-mail04.westnet.com.au" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752080Ab3CDDcY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Mar 2013 22:32:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Frank,

Commit ff43da86c69d76a726ffe7d1666148960dc1d108 ("NET: FEC: dynamtic
check DMA desc buff type") breaks building of the fec ethernet driver
for non CONFIG_ARCH_MXC targets.

=46or example building for ColdFire devices with FEC hardware now
fails like this

drivers/net/ethernet/freescale/fec.c: In function =91fec_enet_get_nextd=
esc=92:
drivers/net/ethernet/freescale/fec.c:215:18: error: invalid use of unde=
fined type =91struct bufdesc_ex=92
drivers/net/ethernet/freescale/fec.c: In function =91fec_enet_get_prevd=
esc=92:
drivers/net/ethernet/freescale/fec.c:224:18: error: invalid use of unde=
fined type =91struct bufdesc_ex=92
drivers/net/ethernet/freescale/fec.c: In function =91fec_enet_start_xmi=
t=92:
drivers/net/ethernet/freescale/fec.c:286:37: error: arithmetic on point=
er to an incomplete type
drivers/net/ethernet/freescale/fec.c:287:13: error: arithmetic on point=
er to an incomplete type
drivers/net/ethernet/freescale/fec.c:324:7: error: dereferencing pointe=
r to incomplete type
etc....

These where generated on 3.9-rc1.

Can you please fix?

Regards
Greg

 =20
