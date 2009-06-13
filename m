From: Torsten Mueller <torsten@archesoft.de>
Subject: Compilation of Realtek r8169-6.010.00 fails on 2.6.30
Date: Sun, 14 Jun 2009 00:28:16 +0200
Message-ID: <4A342800.8070606@archesoft.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Realtek and the Linux r8169 crew <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns3.xtremeweb.de ([217.160.129.106]:3337 "EHLO ns3.xtremeweb.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751315AbZFMWzW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Jun 2009 18:55:22 -0400
Received: from n15-2.dsl.vianetworks.de ([194.77.75.2] helo=slave.xtremeweb.de)
	by ns3.xtremeweb.de with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.60)
	(envelope-from <torsten@archesoft.de>)
	id 1MFbi5-0006n3-Kb
	for netdev@vger.kernel.org; Sun, 14 Jun 2009 00:28:25 +0200
Received: from torsten.localnet.de ([192.168.0.15])
	by slave.xtremeweb.de with esmtpa (Exim 4.69)
	(envelope-from <torsten@archesoft.de>)
	id 1MFbhw-0001ZZ-AA
	for netdev@vger.kernel.org; Sun, 14 Jun 2009 00:28:16 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

i have problems compiling the driver for this card.
I want to test this driver to check, if it gives more
bandwidth in a gigabit network against the stock 2.6.30
vanilla kernel driver.

Can you lead me to a solution for this compilation problem ?

Thanks,
Torsten


slave:/usr/src/rtl8169/r8169-6.010.00 # make clean modules
make -C src/ clean
make[1]: Entering directory `/usr/src/rtl8169/r8169-6.010.00/src'
rm -rf *.o *.ko *~ core* .dep* .*.d .*.cmd *.mod.c *.a *.s .*.flags=20
=2Etmp_versions Module.symvers Modules.symvers rset modules.order=20
Module.markers
make[1]: Leaving directory `/usr/src/rtl8169/r8169-6.010.00/src'
make -C src/ modules
make[1]: Entering directory `/usr/src/rtl8169/r8169-6.010.00/src'
make -C /lib/modules/2.6.30/build=20
SUBDIRS=3D/usr/src/rtl8169/r8169-6.010.00/src modules
make[2]: Entering directory `/usr/src/linux-2.6.30'
   CC [M]  /usr/src/rtl8169/r8169-6.010.00/src/r8169_n.o
/usr/src/rtl8169/r8169-6.010.00/src/r8169_n.c: In function =91rtl8169_o=
pen=92:
/usr/src/rtl8169/r8169-6.010.00/src/r8169_n.c:2753: warning: passing=20
argument 2 of =91request_irq=92 from incompatible pointer type
/usr/src/rtl8169/r8169-6.010.00/src/r8169_n.c: In function=20
=91rtl8169_interrupt=92:
/usr/src/rtl8169/r8169-6.010.00/src/r8169_n.c:3682: error: implicit=20
declaration of function =91netif_rx_schedule_prep=92
/usr/src/rtl8169/r8169-6.010.00/src/r8169_n.c:3683: error: implicit=20
declaration of function =91__netif_rx_schedule=92
/usr/src/rtl8169/r8169-6.010.00/src/r8169_n.c:3714: error: expected=20
expression before =91)=92 token
/usr/src/rtl8169/r8169-6.010.00/src/r8169_n.c:3714: warning: =91return=92=
=20
with a value, in function returning void
/usr/src/rtl8169/r8169-6.010.00/src/r8169_n.c: In function =91rtl8169_p=
oll=92:
/usr/src/rtl8169/r8169-6.010.00/src/r8169_n.c:3735: error: implicit=20
declaration of function =91netif_rx_complete=92
make[3]: *** [/usr/src/rtl8169/r8169-6.010.00/src/r8169_n.o] Error 1
make[2]: *** [_module_/usr/src/rtl8169/r8169-6.010.00/src] Error 2
make[2]: Leaving directory `/usr/src/linux-2.6.30'
make[1]: *** [modules] Error 2
make[1]: Leaving directory `/usr/src/rtl8169/r8169-6.010.00/src'
make: *** [modules] Error 2

slave:/usr/src/rtl8169/r8169-6.010.00 # uname -a
Linux slave 2.6.30 #2 Sat Jun 13 23:31:10 CEST 2009 i686 athlon i386=20
GNU/Linux
slave:/usr/src/rtl8169/r8169-6.010.00 #

