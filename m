From: Sergey Ryazanov <ryazanov.s.a@gmail.com>
Subject: Re: [PATCH 09/28] Remove ATHEROS_AR231X
Date: Mon, 10 Feb 2014 16:05:24 +0400
Message-ID: <CAHNKnsS7Mv4ZhBWZa53go9L9nZimJ7_FG5HFJ9C3kkGMAEz-mA@mail.gmail.com>
References: <1391971686-9517-1-git-send-email-richard@nod.at>
 <1391971686-9517-10-git-send-email-richard@nod.at> <52F7D480.1050106@hauke-m.de>
 <52F7DF21.70207@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Hauke Mehrtens <hauke@hauke-m.de>,
	Jiri Slaby <jirislaby@gmail.com>,
	Nick Kossifidis <mickflemm@gmail.com>,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"open list:ATHEROS ATH5K WIR..." <linux-wireless@vger.kernel.org>,
	"open list:ATHEROS ATH5K WIR..." <ath5k-devel@lists.ath5k.org>,
	open@hauke-m.de,
	"list@hauke-m.de:NETWORKING DRIVERS" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>
To: Richard Weinberger <richard@nod.at>,
	Oleksij Rempel <linux@rempel-privat.de>,
	Jonathan Bither <jonbither@gmail.com>,
	OpenWrt Development List <openwrt-devel@lists.openwrt.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52F7DF21.70207@nod.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-02-10 0:03 GMT+04:00 Richard Weinberger <richard@nod.at>:
> Am 09.02.2014 20:18, schrieb Hauke Mehrtens:
>> On 02/09/2014 07:47 PM, Richard Weinberger wrote:
>>> The symbol is an orphan, get rid of it.
>>>
>>> Signed-off-by: Richard Weinberger <richard@nod.at>
>>> ---
>>>  drivers/net/wireless/ath/ath5k/Kconfig | 10 +++++-----
>>>  drivers/net/wireless/ath/ath5k/ath5k.h | 28 ----------------------------
>>>  drivers/net/wireless/ath/ath5k/base.c  | 14 --------------
>>>  drivers/net/wireless/ath/ath5k/led.c   |  7 -------
>>>  4 files changed, 5 insertions(+), 54 deletions(-)
>>>
>>
>> This code is used in OpenWrt with an out of tree arch code for the
>> Atheros 231x/531x SoC. [0] I do not think anyone is working on adding
>> this code to mainline Linux kernel, because of lack of time/interest.
>
> Sorry, we don't maintain out of tree code.
>

Oleksij, Jonathan do you still working to make ar231x devices work
with upstream, since your posts [1, 2]? Or may be someone from OpenWRT
team would like to add upstream support?

1. https://lkml.org/lkml/2013/5/13/321
2. https://lkml.org/lkml/2013/5/13/358

-- 
BR,
Sergey
