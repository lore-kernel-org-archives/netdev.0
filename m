From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: -next: NET_VENDOR_8390 dependencies
Date: Fri, 28 Oct 2011 22:35:09 +0200
Message-ID: <CAMuHMdU3H63vx8436fdm_WBuPBwqNxHtPiAO9j6RhMn0VCAy2w@mail.gmail.com>
References: <CAMuHMdW6hC1JchxVL9-4f58a8Vg7cF+97BbKePxjEDHY3H8wNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdW6hC1JchxVL9-4f58a8Vg7cF+97BbKePxjEDHY3H8wNw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 23, 2011 at 23:21, Geert Uytterhoeven <geert@linux-m68k.org=
> wrote:
> drivers/net/ethernet/8390/Kconfig:
>
> config NET_VENDOR_8390
> =C2=A0 =C2=A0 =C2=A0 =C2=A0depends on NET_VENDOR_NATSEMI && (AMIGA_PC=
MCIA || PCI || SUPERH || \
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ISA ||=
 MCA || EISA || MAC || M32R || MACH_TX49XX || \
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 MCA_LE=
GACY || H8300 || ARM || MIPS || ZORRO || PCMCIA || \
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 EXPERI=
MENTAL)

> So NET_VENDOR_8390 depends on NET_VENDOR_NATSEMI.

> config NET_VENDOR_NATSEMI
> =C2=A0 =C2=A0 =C2=A0 =C2=A0depends on MCA || MAC || MACH_JAZZ || PCI =
|| XTENSA_PLATFORM_XT2000

> But NET_VENDOR_NATSEMI will never be true for several of the other
> dependencies of NET_VENDOR_8390 (e.g. AMIGA_PCMCIA, EISA, H8300, ARM,
> ZORRO, PCMCIA)?

There's a similar issue with:

config NET_VENDOR_I825XX
        depends on NET_VENDOR_INTEL && (ISA || ISA_DMA_API || ARM || \
                   ARCH_ACORN || MCA || MCA_LEGACY || SNI_RM || SUN3 ||=
 \
                   GSC || BVME6000 || MVME16x || EXPERIMENTAL)

But:

config NET_VENDOR_INTEL
        depends on PCI || PCI_MSI

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
