From: Bernd Schubert <bernd.schubert@pci.uni-heidelberg.de>
Subject: network speed extremly slowed down
Date: Mon, 14 Mar 2005 17:45:06 +0100
Message-ID: <200503141745.08032.bernd.schubert@pci.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

until one hour ago I thought this bug affects only 3com 3c509B cards. Now=
 we=20
go on switching more and more systems from 2.4.X to 2.6.X and it seems th=
at=20
many cards work much slower with 2.6.X

with 2.4.27:
=3D=3D=3D=3D=3D=3D=3D=3D=3D
bernd@pc-brenn bernd>nttcp -T hamilton2
     Bytes  Real s   CPU s Real-MBit/s  CPU-MBit/s   Calls  Real-C/s   CP=
U-C/s
l  8388608    0.72    0.02     92.7710   3355.4432    2048   2831.15  102=
400.0
1  8388608    0.73    0.04     92.0581   1864.3941    5783   7932.96  160=
661.2

with 2.6.11.3:
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

bernd@pc-brenn bernd>nttcp -T hamilton2
     Bytes  Real s   CPU s Real-MBit/s  CPU-MBit/s   Calls  Real-C/s   CP=
U-C/s
l  8388608    3.29    3.28     20.3957     20.4569    2048    622.43     =
624.3
1  8388608    3.29    0.04     20.3923   1637.0411    6143   1866.67  149=
851.2


Cards that show this behaviour:
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Yukon Gigabit Ethernet 10/100/1000Base-T Adapter (sk98lin)
3Com PCI 3c905B Cyclone 100baseTx a
eth0: VIA VT6102 Rhine-II=20

Cards that work fine with 2.4.X and 2.6.X:
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
3Com PCI 3c905C Tornado


The drivers always claim they are using full duplex, here e.g.:

eth0: network connection up using port A
    speed:           100
    autonegotiation: yes
    duplex mode:     full
    flowctrl:        none
    irq moderation:  disabled
    scatter-gather:  enabled


I already reported this issue about the 3C509B on LKML several month ago,=
 but=20
nobody could help. Ever since that mail I got several reports from other=20
people having the same trouble with their cards.

Initially I wanted to write a bug report following the instructions=20
in /usr/src/linux/Documentation/networking/vortex.txt, but since this see=
ms=20
to be more or less a general problem I don't know how to proceed now.


Thanks in advance,
 Bernd


--=20
Bernd Schubert
Physikalisch Chemisches Institut / Theoretische Chemie
Universit=E4t Heidelberg
INF 229
69120 Heidelberg
e-mail: bernd.schubert@pci.uni-heidelberg.de
