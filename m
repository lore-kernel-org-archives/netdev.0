From: Sergey Ryazanov <ryazanov.s.a@gmail.com>
Subject: Re: [PATCH 09/28] Remove ATHEROS_AR231X
Date: Wed, 12 Feb 2014 14:50:30 +0400
Message-ID: <CAHNKnsRQp7WLSJNAXEYPTd=qs1DquOfNgKtHES-Utvcy1=FEgQ@mail.gmail.com>
References: <1391971686-9517-1-git-send-email-richard@nod.at>
 <1391971686-9517-10-git-send-email-richard@nod.at> <52F7D480.1050106@hauke-m.de>
 <52F7DF21.70207@nod.at> <CAHNKnsS7Mv4ZhBWZa53go9L9nZimJ7_FG5HFJ9C3kkGMAEz-mA@mail.gmail.com>
 <52F8C373.9060108@rempel-privat.de> <CAHNKnsQF5Hdf3JT91moPraRQzn4kMpdD2NSiJ7b30wQhS1W4MA@mail.gmail.com>
 <CAGVrzcYnECx5Q=i+m6qZn29y4JALDpw5SWoUNP-S6HgPR3_ygQ@mail.gmail.com> <CAHNKnsRACSo=DfOyiHxqV3acv_wfZmz4tMnYAW0wo4OCibwdfA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Oleksij Rempel <linux@rempel-privat.de>,
	Richard Weinberger <richard@nod.at>,
	Jonathan Bither <jonbither@gmail.com>,
	OpenWrt Development List <openwrt-devel@lists.openwrt.org>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	Jiri Slaby <jirislaby@gmail.com>,
	Nick Kossifidis <mickflemm@gmail.com>,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	"open list:ATHEROS ATH5K WIR..." <linux-wireless@vger.kernel.org>,
	"open list:ATHEROS ATH5K WIR..." <ath5k-devel@lists.ath5k.org>,
	open@hauke-m.de,
	"list@hauke-m.de:NETWORKING DRIVERS" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>,
	"antonynpavlov@gmail.com" <antonynpavlov@gmail.com>,
	Florian Fainelli <florian@openwrt.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f175.google.com ([209.85.160.175]:51623 "EHLO
	mail-yk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752103AbaBLKuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 05:50:51 -0500
In-Reply-To: <CAHNKnsRACSo=DfOyiHxqV3acv_wfZmz4tMnYAW0wo4OCibwdfA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-02-11 3:43 GMT+04:00 Sergey Ryazanov <ryazanov.s.a@gmail.com>:
> 2014-02-11 2:37 GMT+04:00 Florian Fainelli <florian@openwrt.org>:
>> 2014-02-10 4:38 GMT-08:00 Sergey Ryazanov <ryazanov.s.a@gmail.com>:
>>> 2014-02-10 16:17 GMT+04:00 Oleksij Rempel <linux@rempel-privat.de>:
>>>> Am 10.02.2014 13:05, schrieb Sergey Ryazanov:
>>>>> 2014-02-10 0:03 GMT+04:00 Richard Weinberger <richard@nod.at>:
>>>>>> Am 09.02.2014 20:18, schrieb Hauke Mehrtens:
>>>>>>> On 02/09/2014 07:47 PM, Richard Weinberger wrote:
>>>>>>>> The symbol is an orphan, get rid of it.
>>>>>>>>
>>>>>>>> Signed-off-by: Richard Weinberger <richard@nod.at>
>>>>>>>> ---
>>>>>>>>  drivers/net/wireless/ath/ath5k/Kconfig | 10 +++++-----
>>>>>>>>  drivers/net/wireless/ath/ath5k/ath5k.h | 28 ----------------------------
>>>>>>>>  drivers/net/wireless/ath/ath5k/base.c  | 14 --------------
>>>>>>>>  drivers/net/wireless/ath/ath5k/led.c   |  7 -------
>>>>>>>>  4 files changed, 5 insertions(+), 54 deletions(-)
>>>>>>>>
>>>>>>>
>>>>>>> This code is used in OpenWrt with an out of tree arch code for the
>>>>>>> Atheros 231x/531x SoC. [0] I do not think anyone is working on adding
>>>>>>> this code to mainline Linux kernel, because of lack of time/interest.
>>>>>>
>>>>>> Sorry, we don't maintain out of tree code.
>>>>>>
>>>>>
>>>>> Oleksij, Jonathan do you still working to make ar231x devices work
>>>>> with upstream, since your posts [1, 2]? Or may be someone from OpenWRT
>>>>> team would like to add upstream support?
>>>>>
>>>>> 1. https://lkml.org/lkml/2013/5/13/321
>>>>> 2. https://lkml.org/lkml/2013/5/13/358
>>>>>
>>>>
>>>> Hi,
>>>> my current target was to provide barebox and openocd support.
>>>> - ar2313 is already upstream on barebox.
>>>> - ar2315-2318 (barebox) awaiting review by Anthony Pavlov.
>>>> - openocd (EJTAG) support is ready and i'll push it ASUP.
>>>>
>>> WOW, Impressive.
>>
>> That's a nice toy project, although since there are is an existing
>> bootloader with sources, I would have shifted the priority towards
>> getting the kernel support merged such that the bootloader can be used
>> for something. BTW I sent a few devices to Jonathan, not sure if he
>> ever got those...
>>
>>>
>>>> I hope Jonathan do kernel part. If not, i can provide some work, since i
>>>> have testing boards and expiriance on this hardware.
>>>>
>>> If you need, I can test kernel part, or even do some porting work. I
>>> have some AR231x based boards, e.g. Ubnt LS2 and NS2.
>>
>> I guess you could start splitting the OpenWrt patches into a format
>> that makes them suitable for being merged upstream and starting with
>> the MIPS parts. There might be a bunch of checkpatch.pl cleanup work
>> to do before getting those submitted.
>
> I will do that if Jonathan does not have a working solution, which he
> would like to push upstream. So, let's wait for his reply.
>

John, can you delay the merging of this patch for a few months, I will
try to prepare the necessary patches to add AR231x architecture to the
kernel and send them to linux-mips.

-- 
BR,
Sergey
