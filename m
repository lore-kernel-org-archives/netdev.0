From: "Marco Schwarz" <marco.schwarz@gmx.net>
Subject: e1000e-1.1.2 Compile errors with 2.4.37 and gcc 2.95.3
Date: Tue, 09 Feb 2010 10:58:03 +0100
Message-ID: <20100209095803.236980@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:56762 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753627Ab0BIJ6I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Feb 2010 04:58:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I get the following output when trying to compile e1000e-1.1.2 with Lin=
ux Kernel 2.4.37 and gcc 2.95.3 (e1000-8.0.16 compiles fine):

gcc -DDRIVER_E1000E -DDRIVER_NAME=3De1000e -DDRIVER_NAME_CAPS=3DE1000E =
-DLINUX -D__KERNEL__ -DMODULE -O2 -pipe -Wall -I/lib/modules/2.4.37/bui=
ld/include -I. -DMODVERSIONS -DEXPORT_SYMTAB -include /lib/modules/2.4.=
37/build/include/linux/modversions.h  -Wno-sign-compare -fno-strict-ali=
asing   -c -o netdev.o netdev.c
In file included from netdev.c:51:
e1000.h:144: warning: unnamed struct/union that defines no instances
e1000.h:148: warning: unnamed struct/union that defines no instances
netdev.c: In function `e1000_alloc_rx_buffers_ps':
netdev.c:522: structure has no member named `ps_pages'
netdev.c:511: warning: `ps_page' might be used uninitialized in this fu=
nction
netdev.c: In function `e1000_put_txbuf':
netdev.c:859: structure has no member named `length'
netdev.c: In function `e1000_print_hw_hang':
netdev.c:875: structure has no member named `next_to_watch'
netdev.c:906: structure has no member named `time_stamp'
netdev.c:919: warning: pointer type mismatch in conditional expression
netdev.c:919: parse error before `;'
netdev.c: In function `e1000_clean_tx_irq':
netdev.c:940: structure has no member named `next_to_watch'
netdev.c:979: structure has no member named `next_to_watch'
netdev.c:1010: structure has no member named `time_stamp'
netdev.c:935: warning: `eop' might be used uninitialized in this functi=
on
netdev.c: In function `e1000_clean_rx_irq_ps':
netdev.c:1124: structure has no member named `ps_pages'
netdev.c:1154: structure has no member named `ps_pages'
netdev.c:1044: warning: `ps_page' might be used uninitialized in this f=
unction
netdev.c: In function `e1000_clean_jumbo_rx_irq':
netdev.c:1362: warning: pointer type mismatch in conditional expression
netdev.c:1362: parse error before `;'
netdev.c: In function `e1000_clean_rx_ring':
netdev.c:1441: structure has no member named `ps_pages'
netdev.c:1405: warning: `ps_page' might be used uninitialized in this f=
unction
netdev.c: In function `e1000e_set_interrupt_capability':
netdev.c:1876: warning: pointer type mismatch in conditional expression
netdev.c:1876: parse error before `;'
netdev.c:1887: warning: pointer type mismatch in conditional expression
netdev.c:1887: parse error before `;'
netdev.c: In function `e1000e_setup_tx_resources':
netdev.c:2182: warning: pointer type mismatch in conditional expression
netdev.c:2182: parse error before `;'
netdev.c: In function `e1000e_setup_rx_resources':
netdev.c:2206: structure has no member named `ps_pages'
netdev.c:2209: structure has no member named `ps_pages'
netdev.c:2232: structure has no member named `ps_pages'
netdev.c:2236: warning: pointer type mismatch in conditional expression
netdev.c:2236: parse error before `;'
netdev.c: In function `e1000e_free_rx_resources':
netdev.c:2305: structure has no member named `ps_pages'
netdev.c: In function `e1000_alloc_queues':
netdev.c:2466: warning: pointer type mismatch in conditional expression
netdev.c:2466: parse error before `;'
netdev.c: In function `e1000e_reset':
netdev.c:3296: warning: pointer type mismatch in conditional expression
netdev.c:3296: parse error before `;'
netdev.c: In function `e1000_test_msi_interrupt':
netdev.c:3545: warning: pointer type mismatch in conditional expression
netdev.c:3545: parse error before `;'
netdev.c: In function `e1000_test_msi':
netdev.c:3599: warning: pointer type mismatch in conditional expression
netdev.c:3599: parse error before `;'
netdev.c: In function `e1000_open':
netdev.c:3680: warning: pointer type mismatch in conditional expression
netdev.c:3680: parse error before `;'
netdev.c: In function `e1000_phy_read_status':
netdev.c:3982: warning: pointer type mismatch in conditional expression
netdev.c:3982: parse error before `;'
netdev.c: In function `e1000_has_link':
netdev.c:4058: warning: pointer type mismatch in conditional expression
netdev.c:4058: parse error before `;'
netdev.c: In function `e1000_watchdog_task':
netdev.c:4143: warning: pointer type mismatch in conditional expression
netdev.c:4143: parse error before `;'
netdev.c: In function `e1000_tx_csum':
netdev.c:4428: structure has no member named `time_stamp'
netdev.c:4429: structure has no member named `next_to_watch'
netdev.c: In function `e1000_tx_map':
netdev.c:4460: structure has no member named `length'
netdev.c:4462: structure has no member named `time_stamp'
netdev.c:4471: structure has no member named `next_to_watch'
netdev.c:4492: structure has no member named `length'
netdev.c:4493: structure has no member named `time_stamp'
netdev.c:4503: structure has no member named `next_to_watch'
netdev.c:4521: structure has no member named `next_to_watch'
netdev.c: In function `e1000_tx_queue':
netdev.c:4578: structure has no member named `length'
netdev.c: In function `e1000_change_mtu':
netdev.c:4870: warning: pointer type mismatch in conditional expression
netdev.c:4870: parse error before `;'
netdev.c:4877: warning: pointer type mismatch in conditional expression
netdev.c:4877: parse error before `;'
netdev.c: In function `e1000_init_phy_wakeup':
netdev.c:5064: warning: pointer type mismatch in conditional expression
netdev.c:5064: parse error before `;'
netdev.c:5071: warning: pointer type mismatch in conditional expression
netdev.c:5071: parse error before `;'
netdev.c:5077: warning: pointer type mismatch in conditional expression
netdev.c:5077: parse error before `;'
netdev.c: In function `e1000_probe':
netdev.c:5754: warning: pointer type mismatch in conditional expression
netdev.c:5754: parse error before `;'
netdev.c:5796: warning: pointer type mismatch in conditional expression
netdev.c:5796: parse error before `;'
netdev.c:5806: warning: pointer type mismatch in conditional expression
netdev.c:5806: parse error before `;'
make: *** [netdev.o] Error 1

Best regards,
Marco
--=20
Marco Schwarz

Softwareentwicklung
M=F6nchsgasse 10a
67346 Speyer

Tel   06232 602926
=46ax   012120 247701
Mobil 0151 22633892

