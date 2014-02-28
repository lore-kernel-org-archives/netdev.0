From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH v5] can: add Renesas R-Car CAN driver
Date: Fri, 28 Feb 2014 12:41:37 +0100
Message-ID: <CAMuHMdUuaX0pGmdOuJ9CJwj-ZTYo4PqTtZmYHh8swamQ754s2A@mail.gmail.com>
References: <201312270037.15822.sergei.shtylyov@cogentembedded.com>
	<52DCE9E4.7010209@pengutronix.de>
	<52E3148E.2010608@cogentembedded.com>
	<52FCB6C5.6020001@pengutronix.de>
	<53069445.80408@cogentembedded.com>
	<5310521E.6000708@pengutronix.de>
	<53107007.7050802@cogentembedded.com>
	<531074F5.8090702@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	wg@grandegger.com, linux-can@vger.kernel.org,
	Linux-sh list <linux-sh@vger.kernel.org>,
	Pavel Kiryukhin <vksavl@gmail.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <531074F5.8090702@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 28, 2014 at 12:37 PM, Marc Kleine-Budde <mkl@pengutronix.de> wrote:
>>> A 32 bit read/modify/write is a standard operation, nothing special, no
>>> need to worry about byte swapping or anything like this.
>>
>>    Oh, really? 8-)
>>    Don't you know that read[bwlq]() assume little-endian memory layout
>> and to read from big-endian 32-bit register one normally needs readl_be()?
>
> I assume you are on little endian ARM only (for now).
>
> If you use a standard 32 bit read, then modify the correct bits in that
> 32 bit word and write it back, with the corresponding 32 bit write
> everything should be fine. For this usecase you just have yo figure out
> which 24 of the 32 bit are the one you have to change and which are the
> 8 that must not be modified.
>
> Looking at the register layout:
>
>> +     u8 bcr[3];      /* Bit Configuration Register */
>> +     u8 clkr;        /* Clock Select Register */
>
> I think clkr would be the lowest 8 bit and bcr[] are the upper 24.

That would be the outcome on big endian ;-)

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
