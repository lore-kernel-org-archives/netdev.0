From: Adrian Bunk <bunk@stusta.de>
Subject: 2.6.18-rc1-mm2: drivers/char/*synclink* compile errors
Date: Fri, 14 Jul 2006 20:48:25 +0200
Message-ID: <20060714184825.GB3633@stusta.de>
References: <20060713224800.6cbdbf5d.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:37127 "HELO
	mailout.stusta.mhn.de") by vger.kernel.org with SMTP
	id S1161276AbWGNSs1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jul 2006 14:48:27 -0400
To: Andrew Morton <akpm@osdl.org>, Krzysztof Halasa <khc@pm.waw.pl>
Content-Disposition: inline
In-Reply-To: <20060713224800.6cbdbf5d.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Krzysztof, the following compile errors are caused by your commit=20
c2ce920468624d87ec5f91f080ea99681dae6d88 in Linus' tree:

<--  snip  -->

=2E..
  CC      drivers/char/pcmcia/synclink_cs.o
drivers/char/pcmcia/synclink_cs.c: In function =E2=80=98dcd_change=E2=80=
=99:
drivers/char/pcmcia/synclink_cs.c:1171: error: implicit declaration of =
function =E2=80=98hdlc_set_carrier=E2=80=99
=2E..
  CC      drivers/char/synclink.o
drivers/char/synclink.c: In function =E2=80=98mgsl_isr_io_pin=E2=80=99:
drivers/char/synclink.c:1348: error: implicit declaration of function =E2=
=80=98hdlc_set_carrier=E2=80=99
=2E..
  CC      drivers/char/synclinkmp.o
drivers/char/synclinkmp.c: In function =E2=80=98hdlcdev_open=E2=80=99:
drivers/char/synclinkmp.c:1755: error: implicit declaration of function=
 =E2=80=98hdlc_set_carrier=E2=80=99
=2E..
  CC      drivers/char/synclink_gt.o
drivers/char/synclink_gt.c: In function =E2=80=98hdlcdev_open=E2=80=99:
drivers/char/synclink_gt.c:1500: error: implicit declaration of functio=
n =E2=80=98hdlc_set_carrier=E2=80=99

<--   snip  -->

cu
Adrian

--=20

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

