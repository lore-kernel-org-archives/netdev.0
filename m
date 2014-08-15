From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: smsc911x_suspend crash (was: Re: [PATCH] ARM: shmobile: r8a7778:
 Add missing call to shmobile_init_late())
Date: Fri, 15 Aug 2014 10:33:16 +0200
Message-ID: <CAMuHMdXnp4sZBG0_XE-7pk2CmfbS6S1pODAh7uRQ6xWNJHRXmA@mail.gmail.com>
References: <CAMuHMdV7u-9DQ=TGBYSh2GvQgzQE3EAabXoEGU=3N4XyZ_Dx6w@mail.gmail.com>
	<53ECEB7E.9040300@gmail.com>
	<20140814211817.GD2029@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Geert Uytterhoeven <geert+renesas@glider.be>,
	Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>,
	Magnus Damm <magnus.damm@gmail.com>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	Kevin Hilman <khilman@linaro.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Simon Horman <horms@verge.net.au>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20140814211817.GD2029@verge.net.au>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Simon,

On Thu, Aug 14, 2014 at 11:18 PM, Simon Horman <horms@verge.net.au> wrote:
> On Thu, Aug 14, 2014 at 10:01:50AM -0700, Florian Fainelli wrote:
>> On 08/14/2014 01:52 AM, Geert Uytterhoeven wrote:
>> > (taking this to netdev for the crash in smsc911x_suspend())
>> >
>> > On Thu, Aug 14, 2014 at 8:16 AM, Simon Horman <horms@verge.net.au> wrote:
>> >> while this may be part of the puzzle my light testing shows
>> >> that suspend-to-ram does not appear to work with this patch applied.
>>
>> Sounds like you are another victim of:
>> a71e3c37960ce5f9 ("net: phy: Set the driver when registering an MDIO bus
>> device")
>>
>> which got reverted just recently:
>> ce7991e8198b80eb6b4441b6f6114bea4a665d66 ("Revert "net: phy: Set the
>> driver when registering an MDIO bus device"").
>
> Thanks, that did the trick.
>
> Geert, I'll queue up your patch for the r8a7778.

Thanks for testing again!

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
