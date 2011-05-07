From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 7/7] ns: Wire up the setns system call
Date: Sat, 7 May 2011 20:22:19 +0200
Message-ID: <BANLkTimkqOVi0+_azj4UyrQkE8sZL1yCyQ@mail.gmail.com>
References: <m1tyd7p7tq.fsf@fess.ebiederm.org>
	<1304735101-1824-1-git-send-email-ebiederm@xmission.com>
	<1304735101-1824-7-git-send-email-ebiederm@xmission.com>
	<BANLkTi=G-uViB6=8bQ0dRGbw3Gg8V10CRw@mail.gmail.com>
	<m14o56pppd.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	jamal <hadi@cyberus.ca>, Daniel Lezcano <daniel.lezcano@free.fr>,
	Linux Containers <containers@lists.osdl.org>,
	Renato Westphal <renatowestphal@gmail.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m14o56pppd.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, May 7, 2011 at 16:09, Eric W. Biederman <ebiederm@xmission.com>=
 wrote:
> Geert Uytterhoeven <geert@linux-m68k.org> writes:
>
>> On Sat, May 7, 2011 at 04:25, Eric W. Biederman <ebiederm@xmission.c=
om> wrote:
>>> =C2=A0arch/m68k/include/asm/unistd.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =
=C2=A0 =C2=A03 ++-
>>> =C2=A0arch/m68k/kernel/syscalltable.S =C2=A0 =C2=A0 =C2=A0 =C2=A0| =
=C2=A0 =C2=A01 +
>>
>> As the unified syscalltable for m68k/m68knommu is not yet in mainlin=
e
>> (planned for
>> 2.6.40), you should also add it to arch/m68k/kernel/entry_mm.S.
>>
>> Gr{oetje,eeting}s,
>
> Like so?
>
> From c06a03281d944ed36e2da02f5374ec6c650e4988 Mon Sep 17 00:00:00 200=
1
> From: "Eric W. Biederman" <ebiederm@xmission.com>
> Date: Sat, 7 May 2011 07:00:24 -0700
> Subject: [PATCH] m68knommu: Wire up the setns system call
>
> It seems I overlooked m68knommu where I wired up this syscall.

You overlooked m68k with MMU. syscalltable.s is used by m68knommu.

> Reported-by: =C2=A0Geert Uytterhoeven <geert@linux-m68k.org>
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> ---
> =C2=A0arch/m68k/kernel/entry_mm.S | =C2=A0 =C2=A01 +
> =C2=A01 files changed, 1 insertions(+), 0 deletions(-)
>
> diff --git a/arch/m68k/kernel/entry_mm.S b/arch/m68k/kernel/entry_mm.=
S
> index 1359ee6..e048015 100644
> --- a/arch/m68k/kernel/entry_mm.S
> +++ b/arch/m68k/kernel/entry_mm.S
> @@ -754,4 +754,5 @@ sys_call_table:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.long sys_open_by_handle_at
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.long sys_clock_adjtime
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.long sys_syncfs
> + =C2=A0 =C2=A0 =C2=A0 .long sys_setns

Yep.

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
