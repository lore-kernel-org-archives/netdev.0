From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Fri, 10 Jun 2011 22:28:03 +0200
Message-ID: <BANLkTi=fn1qxcJGs7Ngag6ph2uMECiyWLg@mail.gmail.com>
References: <20110609145657.96fae0d0.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Greg KH <greg@kroah.com>, Alexey Dobriyan <adobriyan@gmail.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110609145657.96fae0d0.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 9, 2011 at 06:56, Stephen Rothwell <sfr@canb.auug.org.au> w=
rote:
> I assume that this is fallout from commit a6b7a407865a ("net: remove
> interrupt.h inclusion from netdevice.h").

Ah, that's were the failures on m68k come from:
http://kisskb.ellerman.id.au/kisskb/buildresult/4222666/
http://kisskb.ellerman.id.au/kisskb/buildresult/4223000/

My first bisection between two successive versions of linux-next failed=
, but
the second one between linus and linux-next just finished and points
to that commit.

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
