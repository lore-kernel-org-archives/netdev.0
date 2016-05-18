From: Maxime Coquelin <mcoquelin.stm32-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RESEND PATCH v6 0/6] Add Ethernet support on STM32F429
Date: Wed, 18 May 2016 11:49:44 +0200
Message-ID: <CALszF6AP52EAN68qH8Pup9uxqTnhoT8wigiKaZzgHns3m+NCgQ@mail.gmail.com>
References: <1462789899-13153-1-git-send-email-alexandre.torgue@gmail.com>
	<20160517.122527.1937360418899371800.davem@davemloft.net>
	<CALszF6AE7jkRX3sSNm=PCvEmkmZM-Sv5LxFSj7J3vMbvi8M5Cg@mail.gmail.com>
	<2535270.dCFPoM2olB@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Olof Johansson <olof-nZhT3qVonbNeoWH0uzbU5w@public.gmane.org>,
	Kevin Hilman <khilman-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Alexandre Torgue <alexandre.torgue-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Joachim Eastwood <manabian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2535270.dCFPoM2olB@wuerfel>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2016-05-18 11:31 GMT+02:00 Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>:
> On Wednesday 18 May 2016 09:48:53 Maxime Coquelin wrote:
>> 2016-05-17 18:25 GMT+02:00 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>:
>> > From: Maxime Coquelin <mcoquelin.stm32-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> > Date: Tue, 17 May 2016 11:20:16 +0200
>> >
>> >> Hi David,
>> >>
>> >> 2016-05-09 21:06 GMT+02:00 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>:
>> >>> From: Alexandre TORGUE <alexandre.torgue-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> >>> Date: Mon,  9 May 2016 12:31:33 +0200
>> >>>
>> >>>> STM32F429 Chip embeds a Synopsys 3.50a MAC IP.
>> >>>> This series:
>> >>>>  -enhance current stmmac driver to control it (code already
>> >>>> available) and adds basic glue for STM32F429 chip.
>> >>>>  -Enable basic Net config in kernel.
>> >>>
>> >>> I assume this will go via the ARM tree, for the networking bits:
>> >> I would expect patches 1, 2 & 3 to got via your tree, to avoid conflicts.
>> >
>> > I don't think putting them all via the ARM tree is going to create much
>> > in the way of conflicts, and right now during the merge window offloading
>> > that work from me would really help my backlog a lot.
>>
>> Ok, I understand this is not the best time to pick it.
>>
>> Arnd, Olof & Kevin, would you accept to pick the series in your tree?
>>
>
> It's too late for v4.7 for us too, please pick up the arch/arm patches
> in your normal stm32 tree and send them to us along with any other changes
> you may have, and resend the driver by itself to netdev time after the
> merge window.
>
> The binding document can go either way, with the dts changes or with
> the driver. I see no dependencies between the patches, so we just need
> to land them all in v4.8.

Ok, this is good for me.
No problem to wait for v4.8.
I will take the arch/arm patches, and David the drivers/net/ ones once
v4.7-rc1 is out.

Thanks for your time,
Maxime
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
