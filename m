From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] blutetooth: Remove bogus inline for l2cap_chan_connect()
Date: Mon, 6 Feb 2012 11:41:51 +0100
Message-ID: <CAMuHMdUgyDgOttd+VFJviKw=WCNpt7rjEHC_FCNLfujcr-4m4A@mail.gmail.com>
References: <1326622076-957-1-git-send-email-geert@linux-m68k.org>
	<20120115105203.GA12584@x220.P-661HNU-F1>
	<CAMuHMdVim5VjEYCABXmaw8JQQQtAJk_hLGs+vys2Vr49AFOxCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Geert Uytterhoeven <geert@linux-m68k.org>,
	"Gustavo F. Padovan" <padovan@profusion.mobi>,
	Marcel Holtmann <marcel@holtmann.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdVim5VjEYCABXmaw8JQQQtAJk_hLGs+vys2Vr49AFOxCw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Johan,

On Sun, Jan 15, 2012 at 12:25, Geert Uytterhoeven <geert@linux-m68k.org=
> wrote:
> On Sun, Jan 15, 2012 at 11:52, Johan Hedberg <johan.hedberg@gmail.com=
> wrote:
>>> =C2=A0 =C2=A0 net/bluetooth/l2cap_sock.c: In function =E2=80=98l2ca=
p_sock_connect=E2=80=99:
>>> =C2=A0 =C2=A0 include/net/bluetooth/l2cap.h:838: sorry, unimplement=
ed: inlining failed in call to =E2=80=98l2cap_chan_connect=E2=80=99: fu=
nction body not available
>>> =C2=A0 =C2=A0 net/bluetooth/l2cap_sock.c:126: sorry, unimplemented:=
 called from here
>>> =C2=A0 =C2=A0 make[1]: *** [net/bluetooth/l2cap_sock.o] Error 1
>
>> This was already reported[1] earlier this month and a patch[2] was a=
lso
>
> Ah, it was reported as a sparse warning. I guess that's why I didn't =
find it.
> But a build error is worse.
>
>> created for it which right now resides in my bluetooth-next tree[3].
>> [3] http://git.kernel.org/?p=3Dlinux/kernel/git/jh/bluetooth-next.gi=
t;a=3Dcommitdiff;h=3Dcd555072d0b0738c8a107776fe91902da686f94d

This doesn't seem to be in linux-next, as -next pulls
git://git.kernel.org/pub/scm/linux/kernel/git/padovan/bluetooth-next.gi=
t
instead?

Can we please get the fix in mainline ASAP, as it breaks the build with=
 some
versions of gcc?

Thanks!

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
