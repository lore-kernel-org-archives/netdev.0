From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v5] can: add Renesas R-Car CAN driver
Date: Fri, 28 Feb 2014 16:34:06 +0400
Message-ID: <5310823E.1020104@cogentembedded.com>
References: <201312270037.15822.sergei.shtylyov@cogentembedded.com>	<52DCE9E4.7010209@pengutronix.de>	<52E3148E.2010608@cogentembedded.com>	<52FCB6C5.6020001@pengutronix.de>	<53069445.80408@cogentembedded.com>	<5310521E.6000708@pengutronix.de>	<53107007.7050802@cogentembedded.com>	<531074F5.8090702@pengutronix.de> <CAMuHMdUuaX0pGmdOuJ9CJwj-ZTYo4PqTtZmYHh8swamQ754s2A@mail.gmail.com> <531077AC.7050804@pengutronix.de> <53107B7B.8040800@cogentembedded.com> <063D6719AE5E284EB5DD2968C1650D6D0F6CDC95@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"wg@grandegger.com" <wg@grandegger.com>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	Pavel Kiryukhin <vksavl@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6CDC95@AcuExch.aculab.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 28-02-2014 16:17, David Laight wrote:

>>      This is not a 32-bit register but 24- and 8-bit one. I'm afraid we won't
>> be able to test on BE soon as the machine we're debugging on is LE only.
>> Anyway, for the big-endian configured Superhyway bus the big-endian HPB bus
>> the CAN controller resides on shouldn't swap bytes.

> Except that you aren't going to get any cpu I know about to do a bus
> access with only three of the four byte enables asserted (except as part
> of a misaligned 32 bit transfer).

> So you either have four 8-bit registers, or one 32-bit one.

    I have what is described in the manual, 24-bit register allowing 8-, 16-, 
and 32-bit access.

> I'd suggest keeping both parts in the driver data area

    Well, I'm keeping CLKR value in the platform data. But there is absolutely 
no need to keep BCR anywhere because I'd never use the saved value.

> and oring them together before writing to the device.

    That's what I'm doing.

> 	David

WBR, Sergei

