From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: -next: NET_VENDOR_8390 dependencies
Date: Sun, 23 Oct 2011 23:21:46 +0200
Message-ID: <CAMuHMdW6hC1JchxVL9-4f58a8Vg7cF+97BbKePxjEDHY3H8wNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

drivers/net/ethernet/8390/Kconfig:

config NET_VENDOR_8390
        bool "National Semi-conductor 8390 devices"
        default y
        depends on NET_VENDOR_NATSEMI && (AMIGA_PCMCIA || PCI || SUPERH=
 || \
                   ISA || MCA || EISA || MAC || M32R || MACH_TX49XX || =
\
                   MCA_LEGACY || H8300 || ARM || MIPS || ZORRO || PCMCI=
A || \
                   EXPERIMENTAL)
        ---help---
          If you have a network (Ethernet) card belonging to this class=
, say Y
          and read the Ethernet-HOWTO, available from
          <http://www.tldp.org/docs.html#howto>.

          Note that the answer to this question doesn't directly affect=
 the
          kernel: saying N will just cause the configurator to skip all
          the questions about Western Digital cards. If you say Y, you =
will be
          asked for your specific card in the following questions.

So NET_VENDOR_8390 depends on NET_VENDOR_NATSEMI.

drivers/net/ethernet/natsemi/Kconfig:

config NET_VENDOR_NATSEMI
        bool "National Semi-conductor devices"
        default y
        depends on MCA || MAC || MACH_JAZZ || PCI || XTENSA_PLATFORM_XT=
2000
        ---help---
          If you have a network (Ethernet) card belonging to this class=
, say Y
          and read the Ethernet-HOWTO, available from
          <http://www.tldp.org/docs.html#howto>.

          Note that the answer to this question doesn't directly affect=
 the
          kernel: saying N will just cause the configurator to skip all
          the questions about National Semi-conductor devices. If you s=
ay Y,
          you will be asked for your specific card in the following que=
stions.

But NET_VENDOR_NATSEMI will never be true for several of the other
dependencies of NET_VENDOR_8390 (e.g. AMIGA_PCMCIA, EISA, H8300, ARM,
ZORRO, PCMCIA)?

Gr{oetje,eeting}s,

=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0 =C2=A0=C2=A0 -- Linus Torvalds
