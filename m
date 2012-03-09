From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] m68k/atari: EtherNEC - rewrite to use mainstream ne.c
Date: Fri, 9 Mar 2012 07:35:12 +0100
Message-ID: <CAMuHMdX=4Vn=OsNTp04YcrhDOwz8NOFrWKankj2+3utvEfE-2A@mail.gmail.com>
References: <1327085843-6980-1-git-send-email-geert@linux-m68k.org>
	<4F4B2BB6.900@gmail.com>
	<CAP=VYLqxtE4OamrdN2RXaQu_2kK5_57-x80z48JXzt+xEtQ7pw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Schmitz <schmitzmic@googlemail.com>,
	linux-m68k@vger.kernel.org, netdev@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <CAP=VYLqxtE4OamrdN2RXaQu_2kK5_57-x80z48JXzt+xEtQ7pw@mail.gmail.com>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 9, 2012 at 04:11, Paul Gortmaker
<paul.gortmaker@windriver.com> wrote:
>> diff --git a/drivers/net/ethernet/8390/ne.c b/drivers/net/ethernet/8=
390/ne.c
>> index f92ea2a..28b8781 100644
>> --- a/drivers/net/ethernet/8390/ne.c
>> +++ b/drivers/net/ethernet/8390/ne.c
>> @@ -55,6 +55,9 @@ static const char version2[] =3D
>>
>> =C2=A0#include <asm/system.h>
>> =C2=A0#include <asm/io.h>
>> +#if IS_ENABLED(CONFIG_ATARI_ETHERNEC)
>> +#include <asm/atariints.h>
>> +#endif
>
> Do you really need the #if here? =C2=A0Should be avoidable.

<asm/atariints.h> exists on m68k only, and is not included by any heade=
r in
arch/m68k/include/.

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
