From: Jes Sorensen <Jes.Sorensen@redhat.com>
Subject: Re: [PATCH 2/3] staging/rtl8192e: use s8 instead of char
Date: Wed, 20 Jul 2016 07:25:19 -0400
Message-ID: <wrfjlh0wsg9s.fsf@redhat.com>
References: <20160719153403.2967812-1-arnd@arndb.de>
	<3858062.NGQDOLnTj0@wuerfel> <wrfjlh0xvck3.fsf@redhat.com>
	<4806848.QL77nxBrs4@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-wireless@vger.kernel.org, Kalle Valo <kvalo@codeaurora.org>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Mateusz Kulikowski <mateusz.kulikowski@gmail.com>,
	devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org,
	Andrea Merello <andrea.merello@gmail.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4806848.QL77nxBrs4@wuerfel> (Arnd Bergmann's message of "Wed, 20
	Jul 2016 10:25:21 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd@arndb.de> writes:
> On Tuesday, July 19, 2016 12:05:00 PM CEST Jes Sorensen wrote:
>> Arnd Bergmann <arnd@arndb.de> writes:
>> I think that would be better, albeit not a big issue. 
>
> Ok, and since Kalle applied the first patch to his tree, I'm now sending
> a series of three patches that are all for Greg, which also avoids some
> possible confusion.

Awesome!

>> I'd like to get rid of all the drivers/staging/rtl* drivers eventually 
>
> That would be great, yes.
>
> Can you clarify what the long-term plan is? I see that
> drivers/net/wireless/realtek/rtlwifi/ has most of the PCIe parts
> and one USB device (rtl8192cu/rtl8188cus) while
> drivers/net/wireless/rtl8xxx has all the USB parts including
> that one.
>
> Does that mean we want the staging drivers for PCIe devices
> to get merged into rtlwifi, and the remaining USB drivers to get
> replaced by r8xxxu?

Well it really all depends on how much time I have and how much others
step up and help contribute to the code. For rtl8xxxu my plans are as
follows:

1) rtl8188eu support, since this is the most widely distributed USB
dongle which isn't currently supported by a non staging driver. I am
currently working on this together with Andrea Merello.

2) Beacon support for IBSS and AP mode - hopefully this should make it
possible to default rtl8xxxu for rtl8192cu/rtl8188cu devices and disable
them in rtlwifi.

3) SDIO device support

4) PCI device support

5) 802.11ac device support

3/4/5 not necessarily in that order. There really is no reason why
rtl8xxxu shouldn't have SDIO and PCI device support added so the core
code can be shared.

> As one data point that I can provide (but you are probably
> aware of), I could never get my rtl8188cus stick to work with
> rtlwifi, but I found the older r8712u device to work fine with
> the staging/rtl8712 driver.

I'd love to hear if the rtl8188cus works better with rtl8xxxu. For the
rtl8712 device, rtl8192su?, then potentially that could be added to
rtl8xxxu as well, but it's not a top priority on my list right now.

Cheers,
Jes
