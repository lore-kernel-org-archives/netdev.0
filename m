From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Subject: [BUILD_FAILURE] linux-next: Tree for March 31 build fails with CONFIG_SLICOSS=y
Date: Mon, 31 Mar 2008 18:47:10 +0530
Message-ID: <47F0E456.5080201@linux.vnet.ibm.com>
References: <20080331181118.7964d4a9.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Andy Whitcroft <apw@shadowen.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from E23SMTP05.au.ibm.com ([202.81.18.174]:60013 "EHLO
	e23smtp05.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755530AbYCaNRR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2008 09:17:17 -0400
In-Reply-To: <20080331181118.7964d4a9.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

The kernel next-20080331 kernel build fails with Alacritech's IS-NIC gi=
gabit ethernet
driver on powerpc with allyesconfig (with # CONFIG_NOVFS is not set)

  CC      drivers/net/slicoss/slicoss.o
drivers/net/slicoss/slicoss.c: In function =91slic_xmit_build_request=92=
:
drivers/net/slicoss/slicoss.c:933: error: =91Stop=92 undeclared (first =
use in this function)
drivers/net/slicoss/slicoss.c:933: error: (Each undeclared identifier i=
s reported only once
drivers/net/slicoss/slicoss.c:933: error: for each function it appears =
in.)
drivers/net/slicoss/slicoss.c:933: error: expected =91;=92 before =91Co=
mpilation=92
drivers/net/slicoss/slicoss.c: In function =91slic_link_event_handler=92=
:
drivers/net/slicoss/slicoss.c:1420: error: =91Stop=92 undeclared (first=
 use in this function)
drivers/net/slicoss/slicoss.c:1420: error: expected =91;=92 before =91c=
ompilation=92
drivers/net/slicoss/slicoss.c: In function =91slic_if_init=92:
drivers/net/slicoss/slicoss.c:1848: error: =91Stop=92 undeclared (first=
 use in this function)
drivers/net/slicoss/slicoss.c:1848: error: expected =91;=92 before =91C=
ompilations=92
drivers/net/slicoss/slicoss.c: In function =91slic_card_init=92:
drivers/net/slicoss/slicoss.c:2518: warning: cast from pointer to integ=
er of different size
drivers/net/slicoss/slicoss.c: In function =91slic_timer_get_stats=92:
drivers/net/slicoss/slicoss.c:3269: error: =91Stop=92 undeclared (first=
 use in this function)
drivers/net/slicoss/slicoss.c:3269: error: expected =91;=92 before =91c=
ompilation=92
drivers/net/slicoss/slicoss.c: In function =91slic_link_upr_complete=92=
:
drivers/net/slicoss/slicoss.c:3683: error: =91Stop=92 undeclared (first=
 use in this function)
drivers/net/slicoss/slicoss.c:3683: error: expected =91;=92 before =91C=
ompilation=92
drivers/net/slicoss/slicoss.c: In function =91slic_eeprom_cksum=92:
drivers/net/slicoss/slicoss.c:3806: warning: cast from pointer to integ=
er of different size
drivers/net/slicoss/slicoss.c: In function =91slic_rspqueue_init=92:
drivers/net/slicoss/slicoss.c:3901: warning: cast from pointer to integ=
er of different size
drivers/net/slicoss/slicoss.c:3901: warning: cast from pointer to integ=
er of different size
drivers/net/slicoss/slicoss.c: In function =91slic_rspqueue_getnext=92:
drivers/net/slicoss/slicoss.c:3990: warning: cast from pointer to integ=
er of different size
drivers/net/slicoss/slicoss.c:3990: warning: cast from pointer to integ=
er of different size
drivers/net/slicoss/slicoss.c:4004: warning: cast from pointer to integ=
er of different size
drivers/net/slicoss/slicoss.c:4004: warning: cast from pointer to integ=
er of different size
drivers/net/slicoss/slicoss.c:4009: warning: cast from pointer to integ=
er of different size
drivers/net/slicoss/slicoss.c:4009: warning: cast from pointer to integ=
er of different size
drivers/net/slicoss/slicoss.c: In function =91slic_cmdqmem_addpage=92:
drivers/net/slicoss/slicoss.c:4056: warning: cast from pointer to integ=
er of different size
drivers/net/slicoss/slicoss.c:4056: warning: cast from pointer to integ=
er of different size
drivers/net/slicoss/slicoss.c: In function =91slic_cmdq_init=92:
drivers/net/slicoss/slicoss.c:4081: warning: cast from pointer to integ=
er of different size
drivers/net/slicoss/slicoss.c:4081: warning: cast from pointer to integ=
er of different size
drivers/net/slicoss/slicoss.c: In function =91slic_cmdq_addcmdpage=92:
drivers/net/slicoss/slicoss.c:4184: error: implicit declaration of func=
tion =91virt_to_bus=92
drivers/net/slicoss/slicoss.c:4224: warning: cast from pointer to integ=
er of different size
drivers/net/slicoss/slicoss.c:4224: warning: cast from pointer to integ=
er of different size
drivers/net/slicoss/slicoss.c:4230: warning: cast from pointer to integ=
er of different size
drivers/net/slicoss/slicoss.c:4230: warning: cast from pointer to integ=
er of different size
drivers/net/slicoss/slicoss.c: In function =91slic_cmdq_getdone=92:
drivers/net/slicoss/slicoss.c:4271: warning: cast from pointer to integ=
er of different size
drivers/net/slicoss/slicoss.c:4271: warning: cast from pointer to integ=
er of different size
drivers/net/slicoss/slicoss.c: In function =91slic_cmdq_putdone=92:
drivers/net/slicoss/slicoss.c:4287: warning: cast from pointer to integ=
er of different size
drivers/net/slicoss/slicoss.c:4287: warning: cast from pointer to integ=
er of different size
drivers/net/slicoss/slicoss.c:4289: warning: cast from pointer to integ=
er of different size
drivers/net/slicoss/slicoss.c:4289: warning: cast from pointer to integ=
er of different size
drivers/net/slicoss/slicoss.c: In function =91slic_cmdq_putdone_irq=92:
drivers/net/slicoss/slicoss.c:4301: warning: cast from pointer to integ=
er of different size
drivers/net/slicoss/slicoss.c:4301: warning: cast from pointer to integ=
er of different size
drivers/net/slicoss/slicoss.c:4303: warning: cast from pointer to integ=
er of different size
drivers/net/slicoss/slicoss.c:4303: warning: cast from pointer to integ=
er of different size
drivers/net/slicoss/slicoss.c: In function =91slic_rcvqueue_fill=92:
drivers/net/slicoss/slicoss.c:4425: warning: cast from pointer to integ=
er of different size
drivers/net/slicoss/slicoss.c: In function =91slic_rcvqueue_reinsert=92=
:
drivers/net/slicoss/slicoss.c:4504: warning: cast from pointer to integ=
er of different size
make[3]: *** [drivers/net/slicoss/slicoss.o] Error 1
make[2]: *** [drivers/net/slicoss] Error 2
make[1]: *** [drivers/net] Error 2
make: *** [drivers] Error 2



--=20
Thanks & Regards,
Kamalesh Babulal,
Linux Technology Center,
IBM, ISTL.
