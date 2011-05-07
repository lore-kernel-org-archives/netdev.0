From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 7/7] ns: Wire up the setns system call
Date: Sat, 7 May 2011 10:27:17 +0200
Message-ID: <BANLkTi=G-uViB6=8bQ0dRGbw3Gg8V10CRw@mail.gmail.com>
References: <m1tyd7p7tq.fsf@fess.ebiederm.org>
	<1304735101-1824-1-git-send-email-ebiederm@xmission.com>
	<1304735101-1824-7-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	jamal <hadi@cyberus.ca>, Daniel Lezcano <daniel.lezcano@free.fr>,
	Linux Containers <containers@lists.osdl.org>,
	Renato Westphal <renatowestphal@gmail.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1304735101-1824-7-git-send-email-ebiederm@xmission.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, May 7, 2011 at 04:25, Eric W. Biederman <ebiederm@xmission.com>=
 wrote:
> =C2=A0arch/m68k/include/asm/unistd.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=
=A0 =C2=A03 ++-
> =C2=A0arch/m68k/kernel/syscalltable.S =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=
=A0 =C2=A01 +

As the unified syscalltable for m68k/m68knommu is not yet in mainline
(planned for
2.6.40), you should also add it to arch/m68k/kernel/entry_mm.S.

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
