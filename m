From: Robert Hancock <hancockrwd@gmail.com>
Subject: Re: [Regression] r8169: enable 64-bit DMA by default for PCI Express
 devices (v2)
Date: Sat, 27 Mar 2010 11:46:12 -0600
Message-ID: <4BAE4464.9060909@gmail.com>
References: <20100315150806.GA15354@Dublin.logfs.org> <20100315151041.GA15667@Dublin.logfs.org> <20100315.115748.13754030.davem@davemloft.net> <51f3faa71003151628g5edc4d7av8916ac76cb337bfe@mail.gmail.com> <20100316083501.GA3489@Dublin.logfs.org> <51f3faa71003161630g69160ea9tc1a2d448682632e5@mail.gmail.com> <51f3faa71003251756h17374375yd3a5d2acee2ffab9@mail.gmail.com> <20100326091234.GA11959@Dublin.logfs.org> <4BAD65A0.7090309@gmail.com> <20100327063838.GB11959@Dublin.logfs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	romieu@fr.zoreil.com
To: =?UTF-8?B?77+9IEVuZ2Vs?= <joern@dublin.logfs.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100327063838.GB11959@Dublin.logfs.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/27/2010 12:38 AM, =EF=BF=BD Engel wrote:
> On Fri, 26 March 2010 19:55:44 -0600, Robert Hancock wrote:
>>
>> Well, that one's 36 bits, but it's unclear whether that driver would
>> actually be likely to access anything over 4GB. It's possible that
>> there's just some general problem with 64-bit DMA on that machine.
>
> That may very well be.  I've had trouble using a PCIe card in that
> machine as well.  "Solution" was to buy a different computer.  Sad, I
> know, but not my money.

Hm, do you recall/have the details of what happened with the other card=
?

It's possible this is some general problem with that machine/motherboar=
d=20
and not actually an issue with what the driver is doing. What kind of=20
board is that?

>
>> The fact that even stuff like lspci and MII is breaking seems odd,
>> though. It could be that model of card doesn't like the PCIDAC regis=
ter
>> bit being set (maybe it means something different on that model, or
>> something).
>>
>> I suppose a publicly accessible datasheet for these chips is too muc=
h to
>> hope for?
>
> Which chips?
>
> J=EF=BF=BDrn
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
