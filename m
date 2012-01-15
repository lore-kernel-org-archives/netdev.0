From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] blutetooth: Remove bogus inline for l2cap_chan_connect()
Date: Sun, 15 Jan 2012 12:25:04 +0100
Message-ID: <CAMuHMdVim5VjEYCABXmaw8JQQQtAJk_hLGs+vys2Vr49AFOxCw@mail.gmail.com>
References: <1326622076-957-1-git-send-email-geert@linux-m68k.org>
	<20120115105203.GA12584@x220.P-661HNU-F1>
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
In-Reply-To: <20120115105203.GA12584@x220.P-661HNU-F1>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Johan,

On Sun, Jan 15, 2012 at 11:52, Johan Hedberg <johan.hedberg@gmail.com> =
wrote:
>> =C2=A0 =C2=A0 net/bluetooth/l2cap_sock.c: In function =E2=80=98l2cap=
_sock_connect=E2=80=99:
>> =C2=A0 =C2=A0 include/net/bluetooth/l2cap.h:838: sorry, unimplemente=
d: inlining failed in call to =E2=80=98l2cap_chan_connect=E2=80=99: fun=
ction body not available
>> =C2=A0 =C2=A0 net/bluetooth/l2cap_sock.c:126: sorry, unimplemented: =
called from here
>> =C2=A0 =C2=A0 make[1]: *** [net/bluetooth/l2cap_sock.o] Error 1

> This was already reported[1] earlier this month and a patch[2] was al=
so

Ah, it was reported as a sparse warning. I guess that's why I didn't fi=
nd it.
But a build error is worse.

> created for it which right now resides in my bluetooth-next tree[3].

OK, thanks a lot!

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
