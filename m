From: =?iso-8859-2?Q?Pawe=B3_Soko=B3owski?= <falcon@muflon.linux.pl>
Subject: 2.6.4-rc1 + hp100 EISA, not working
Date: Sun, 29 Feb 2004 22:06:16 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0402292149230.25624@don.falconne.eu.org>
Reply-To: pawel.sokolowski@muflon.linux.pl
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-2
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi.

I have HP 10/100VG AnyLan EISA card. My machine is a HP Netserver
4d/66LE. 486, EISA only.

After latest changes in hp100 driver, it stopped working for me.

It oopsed as module on 2.6.2 (and I experienced kernel panic when hp100
was build in) but after Oops I was able to get interface up and working:

hp100: eth0: HP J2577 at 0x2c38, IRQ 5, EISA bus, 128k SRAM (rx/tx 75%).
hp100: eth0: Memory area at 0xd0000-0xd3fff (virtual base c00d0000).
hp100: eth0: Adapter is attached to 10Mb/s network (10baseT).


On 2.6.3 it just Oopsed and didn't work. On 2.6.4-rc1 it does
not oops but it doesn't work (neither as module nor as build in kernel).
Module loads cleanly but does nothing - I can't get interface up,
nothing in dmesg.

If you need more details, logs etc., please tell me what you need to
know.



I don't know if it's related to this problem but at earlier stage of
booting I'm getting following messages:

EISA: Probing bus 0 at eisa0
EISA: Mainboard HWPC061 detected.
EISA: slot 2 : HWP1940 detected (disabled).
EISA: Detected 1 card.

Card works fine on 2.4.* (tested on 2.4.16, 2.4.24,25,26-pre1) :
hp100: eth0: HP J2577 at 0x2c38, IRQ 5, EISA bus, 128k SRAM (rx/tx 75%%).
hp100: eth0: Memory area at 0xd0000-0xd3fff (virtual base c00d0000).
hp100: eth0: Adapter is attached to 10Mb/s network.


--=20
  ,d$$$$$P.d$$b     d$P  ,gd$$$$$,gd$$$$g. ,$$$b._$$P               RLU #=
172534
  ggggggggggggg.   ggs  ,gg     ,gg    ,gg ggp,ggggg           Pawe=B3 So=
ko=B3owski
 d$P""""'""""Y$$. d$P   d$P     d$P   ,d$Pd$P `Y$$P      falcon@muflon.li=
nux.pl
d$P           Y$$d$$$$$P`Y$$$$$'`Y$$$$$P'd$P   d$P    Replicant (M) Des: =
Falcon
