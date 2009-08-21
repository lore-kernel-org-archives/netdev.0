From: Manuel Lauss <manuel.lauss@googlemail.com>
Subject: Re: [PATCH 1/2] alchemy: add au1000-eth platform device
Date: Fri, 21 Aug 2009 19:23:39 +0200
Message-ID: <f861ec6f0908211023t3eb7ff1p12b6160feb94efb4@mail.gmail.com>
References: <200908170105.38154.florian@openwrt.org>
	 <4A8AC125.3020602@ru.mvista.com>
	 <200908181801.41602.florian@openwrt.org>
	 <200908211853.07969.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sergei Shtylyov <sshtylyov@ru.mvista.com>,
	Ralf Baechle <ralf@linux-mips.org>, linux-mips@linux-mips.org,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Florian Fainelli <florian@openwrt.org>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <200908211853.07969.florian@openwrt.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

Hi Florian,

On Fri, Aug 21, 2009 at 6:53 PM, Florian Fainelli<florian@openwrt.org> =
wrote:
> Le Tuesday 18 August 2009 18:01:40 Florian Fainelli, vous avez =E9cri=
t=A0:
>> Le Tuesday 18 August 2009 16:56:37 Sergei Shtylyov, vous avez =E9cri=
t=A0:
>> > Hello.
>> >
>> > Florian Fainelli wrote:
>> > > This patch adds the board code to register a per-board au1000-et=
h
>> > > platform device to be used wit the au1000-eth platform driver in=
 a
>> > > subsequent patch. Note that the au1000-eth driver knows about th=
e
>> > > default driver settings such that we do not need to pass any
>> > > platform_data informations in most cases except db1x00.
>> >
>> > =A0 =A0 Sigh, NAK...
>> > =A0 =A0 Please don't register the SoC device per board, do it in
>> > alchemy/common/platfrom.c and find a way to pass the board specifi=
c
>> > platform data from the board file there instead -- something like
>> > arch/arm/mach-davinci/usb.c does.
>>
>> Ok, like I promised, this was the per-board device registration. Do =
you
>> prefer something like this: --
>> From fd75b7c7fa3c05c21122c43e43260d2785475a79 Mon Sep 17 00:00:00 20=
01
>> From: Florian Fainelli <florian@openwrt.org>
>> Date: Tue, 18 Aug 2009 17:53:21 +0200
>> Subject: [PATCH] alchemy: add au1000-eth platform device (v2)
>>
>> This patch makes the board code register the au1000-eth
>> platform device. The au1000-eth platform data can be
>> overriden with the au1xxx_override_eth0_cfg function
>> like it has to be done for the Bosporus board.
>
> Sergei, any comments on that version? What about you Manuel?

Obviously I *much* prefer your first version, but I'm okay with this
second version too.

(I usually only comment if I don't like things, so take my silence as
approval).

Thanks for your work!

Manuel Lauss
