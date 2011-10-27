From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: drivers/net/ethernet/apple
Date: Thu, 27 Oct 2011 10:40:30 +0200
Message-ID: <CAMuHMdUXg3D=+dCHZ=OwzfD2eejSaB73Y-sgv2cXoH4cnjzV5w@mail.gmail.com>
References: <CAMuHMdXxqKoPNNo9a+VK-Yzu0Qp-8zY2+OhHL6pDPF=dsnNK5Q@mail.gmail.com>
	<CAMuHMdUW5PjPU7qNOPA16CbxHJs-bL4r+aFcEGV95SDRBotXRg@mail.gmail.com>
	<1319701536.10258.74.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: jeffrey.t.kirsher@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1319701536.10258.74.camel@jtkirshe-mobl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 27, 2011 at 09:45, Jeff Kirsher <jeffrey.t.kirsher@intel.co=
m> wrote:
> On Wed, 2011-10-26 at 22:16 -0700, Geert Uytterhoeven wrote:
>> On Tue, Oct 25, 2011 at 22:19, Geert Uytterhoeven
>> <geert@linux-m68k.org> wrote:
>> > drivers/net/ethernet/apple/mac89x0.c is a driver for the Crystal
>> Semiconductor
>> > (Now Cirrus Logic) CS89[02]0, so it belongs in
>> drivers/net/ethernet/cirrus,
>> > next to cs89x0.c.
>>
>> And on the first -next run since its inclusion:
>>
>> | drivers/net/ethernet/apple/mac89x0.c:107:20: error: cs89x0.h: No
>> such file or directory
>>
>> it needs the (shared) header file which is in
>> drivers/net/ethernet/cirrus/.
>>
>> http://kisskb.ellerman.id.au/kisskb/buildresult/4835488/
>
> Ah, yeah, now it is coming back to me why I placed cs89x0.[ch] in the
> drivers/net/ethernet/apple/ because it was grouped with the "common"
> drivers. =C2=A0The intent was to group drivers that use common code t=
ogether.
>
> I can put together a patch to fix this if you are not able to.

I will create a patch to move mac89x0 to .../cirrus, when I get to comp=
iling a
Mac kernel myself.

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
