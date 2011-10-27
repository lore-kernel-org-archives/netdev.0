From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: drivers/net/ethernet/apple
Date: Thu, 27 Oct 2011 07:16:54 +0200
Message-ID: <CAMuHMdUW5PjPU7qNOPA16CbxHJs-bL4r+aFcEGV95SDRBotXRg@mail.gmail.com>
References: <CAMuHMdXxqKoPNNo9a+VK-Yzu0Qp-8zY2+OhHL6pDPF=dsnNK5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdXxqKoPNNo9a+VK-Yzu0Qp-8zY2+OhHL6pDPF=dsnNK5Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

On Tue, Oct 25, 2011 at 22:19, Geert Uytterhoeven <geert@linux-m68k.org=
> wrote:
> drivers/net/ethernet/apple/mac89x0.c is a driver for the Crystal Semi=
conductor
> (Now Cirrus Logic) CS89[02]0, so it belongs in drivers/net/ethernet/c=
irrus,
> next to cs89x0.c.

And on the first -next run since its inclusion:

| drivers/net/ethernet/apple/mac89x0.c:107:20: error: cs89x0.h: No
such file or directory

it needs the (shared) header file which is in drivers/net/ethernet/cirr=
us/.

http://kisskb.ellerman.id.au/kisskb/buildresult/4835488/

> And according to drivers/net/ethernet/apple/mace.h, "mace" is the
> "Am79C940 MACE (Medium Access Control for Ethernet)", so mace and
> macmace should be in drivers/net/ethernet/amd/.

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
