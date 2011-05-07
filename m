From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 7/7] ns: Wire up the setns system call
Date: Sat, 07 May 2011 07:09:34 -0700
Message-ID: <m14o56pppd.fsf@fess.ebiederm.org>
References: <m1tyd7p7tq.fsf@fess.ebiederm.org>
	<1304735101-1824-1-git-send-email-ebiederm@xmission.com>
	<1304735101-1824-7-git-send-email-ebiederm@xmission.com>
	<BANLkTi=G-uViB6=8bQ0dRGbw3Gg8V10CRw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	jamal <hadi@cyberus.ca>, Daniel Lezcano <daniel.lezcano@free.fr>,
	Linux Containers <containers@lists.osdl.org>,
	Renato Westphal <renatowestphal@gmail.com>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <BANLkTi=G-uViB6=8bQ0dRGbw3Gg8V10CRw@mail.gmail.com> (Geert
	Uytterhoeven's message of "Sat, 7 May 2011 10:27:17 +0200")
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Geert Uytterhoeven <geert@linux-m68k.org> writes:

> On Sat, May 7, 2011 at 04:25, Eric W. Biederman <ebiederm@xmission.co=
m> wrote:
>> =C2=A0arch/m68k/include/asm/unistd.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=
=A0 =C2=A03 ++-
>> =C2=A0arch/m68k/kernel/syscalltable.S =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=
=A0 =C2=A01 +
>
> As the unified syscalltable for m68k/m68knommu is not yet in mainline
> (planned for
> 2.6.40), you should also add it to arch/m68k/kernel/entry_mm.S.
>
> Gr{oetje,eeting}s,

Like so?

=46rom c06a03281d944ed36e2da02f5374ec6c650e4988 Mon Sep 17 00:00:00 200=
1
=46rom: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Sat, 7 May 2011 07:00:24 -0700
Subject: [PATCH] m68knommu: Wire up the setns system call

It seems I overlooked m68knommu where I wired up this syscall.

Reported-by:  Geert Uytterhoeven <geert@linux-m68k.org>
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 arch/m68k/kernel/entry_mm.S |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/arch/m68k/kernel/entry_mm.S b/arch/m68k/kernel/entry_mm.S
index 1359ee6..e048015 100644
--- a/arch/m68k/kernel/entry_mm.S
+++ b/arch/m68k/kernel/entry_mm.S
@@ -754,4 +754,5 @@ sys_call_table:
 	.long sys_open_by_handle_at
 	.long sys_clock_adjtime
 	.long sys_syncfs
+	.long sys_setns
=20
--=20
1.7.5.1.217.g4e3aa

--
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
