From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] m68k/atari: EtherNEC - rewrite to use mainstream ne.c,
 take two
Date: Fri, 6 Apr 2012 10:28:32 +0200
Message-ID: <CAMuHMdVYULaeNp=6bBNn7_RMG9YoDFTyJnXQxTeY2AozHpUL2Q@mail.gmail.com>
References: <1327085843-6980-1-git-send-email-geert@linux-m68k.org>
	<4F4B2BB6.900@gmail.com>
	<CAP=VYLqxtE4OamrdN2RXaQu_2kK5_57-x80z48JXzt+xEtQ7pw@mail.gmail.com>
	<CAMuHMdX=4Vn=OsNTp04YcrhDOwz8NOFrWKankj2+3utvEfE-2A@mail.gmail.com>
	<4F5A0679.1020604@windriver.com>
	<4F7816B0.3090802@gmail.com>
	<4F7CB31D.8060002@windriver.com>
	<CAMuHMdWSzG4npwjpJ=cwNFKhyBZjvgPn1sp6nZ2re6QsRWPpXg@mail.gmail.com>
	<4F7E184B.6000903@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	linux-m68k@vger.kernel.org, netdev@vger.kernel.org
To: Michael Schmitz <schmitzmic@googlemail.com>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <4F7E184B.6000903@gmail.com>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 6, 2012 at 00:10, Michael Schmitz <schmitzmic@googlemail.co=
m> wrote:
>> Indeed, with a small modification (keep multi-platform kernels in mi=
nd):
>>
>> #ifdef CONFIG_ATARI
>> #define EI_IRQ_FLAGS =C2=A0 =C2=A0(MACH_IS_ATARI ? IRQF_SHARED : 0)
>> #else
>> #define EI_IRQ_FLAGS =C2=A0 =C2=A00
>> #endif
>>
>
> Right you are. Is any other m68k platform using ne.c directly, or do =
you
> plan to convert all other NE2000 based drivers to ne.c now?

Plain ne is also used on Q40.

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
