From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: [PATCH 1/1] posix clocks: introduce syscall for clock tuning.
Date: Mon, 23 Aug 2010 04:22:58 -0400
Message-ID: <AANLkTi=HFyMpXEjpyHmL-79qzXLQWEfiW+KiJHnrJRW2@mail.gmail.com>
References: <cover.1282550649.git.richard.cochran@omicron.at> <e253843e07ce5d15c2c8d11ce786bf979ed85ca5.1282550649.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e253843e07ce5d15c2c8d11ce786bf979ed85ca5.1282550649.git.richard.cochran@omicron.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 23, 2010 at 04:16, Richard Cochran wrote:
> --- a/arch/blackfin/include/asm/unistd.h
> +++ b/arch/blackfin/include/asm/unistd.h
> @@ -389,8 +389,9 @@
> =C2=A0#define __NR_rt_tgsigqueueinfo 368
> =C2=A0#define __NR_perf_event_open =C2=A0 369
> =C2=A0#define __NR_recvmmsg =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0370
> +#define __NR_clock_adjtime =C2=A0 =C2=A0 371
>
> -#define __NR_syscall =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 371
> +#define __NR_syscall =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 372
> =C2=A0#define NR_syscalls =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__=
NR_syscall
>
> =C2=A0/* Old optional stuff no one actually uses */
> --- a/arch/blackfin/mach-common/entry.S
> +++ b/arch/blackfin/mach-common/entry.S
> @@ -1628,6 +1628,7 @@ ENTRY(_sys_call_table)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.long _sys_rt_tgsigqueueinfo
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.long _sys_perf_event_open
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.long _sys_recvmmsg =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 /* 370 */
> + =C2=A0 =C2=A0 =C2=A0 .long _sys_clock_adjtime
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.rept NR_syscalls-(.-_sys_call_table)/4
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.long _sys_ni_syscall

=46YI, this is going to hit a conflict as i'm about to push out an
update to wire up the new 2.6.36 syscalls
-mike
