From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 0/3] Fix 8390 regressions
Date: Fri, 13 May 2011 07:17:04 +0200
Message-ID: <BANLkTi=y6_0NtZSyMovjV7wfbH5i_caEhw@mail.gmail.com>
References: <1305227500-15595-1-git-send-email-geert@linux-m68k.org>
	<20110512.170254.1553444447781324461.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, ysato@users.sourceforge.jp,
	linux@arm.linux.org.uk, fthain@telegraphics.com.au,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-m68k@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110512.170254.1553444447781324461.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 12, 2011 at 23:02, David Miller <davem@davemloft.net> wrote=
:
> From: Geert Uytterhoeven <geert@linux-m68k.org>
> Date: Thu, 12 May 2011 19:11:37 +0000
>
>> These patches fix regressions in 3 8390-based network drivers:
>> =C2=A0[1/3] zorro8390: Fix regression caused during net_device_ops c=
onversion
>> =C2=A0[2/3] hydra: Fix regression caused during net_device_ops conve=
rsion
>> =C2=A0[3/3] ne-h8300: Fix regression caused during net_device_ops co=
nversion
>>
>> The first one, for zorro8390, has been tested.
>> The second one, for hydra, has been compile-tested only.
>>
>> Based on commits 8cfd9e923be54ef66ce174a93f4592b444b96407 ("[ARM] Ri=
scPC: Fix
>> etherh oops") and 217cbfa856dc1cbc2890781626c4032d9e3ec59f ("mac8390=
: fix
>> regression caused during net_device_ops conversion"), and the patch =
for
>> zorro8390, we have good reasons to believe hydra and ne-h8300 are af=
fected
>> as well, as they all include lib8390.c.
>> Hence patches for those are also included, although I could not test=
 them.
>
> All applied, thanks Geert, and I made the "From: " removals you reque=
sted.

Thanks a lot!

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
