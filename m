From: Maxime Coquelin <maxime.coquelin-qxv4g6HH51o@public.gmane.org>
Subject: Re: [PATCH v2 0/7] Fix sti drivers whcih mix reg address spaces
Date: Wed, 14 Jan 2015 13:17:08 +0100
Message-ID: <54B65E44.7060901@st.com>
References: <1420643052-4506-1-git-send-email-peter.griffin@linaro.org> <20150111.185445.1288456704842706068.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <srinivas.kandagatla-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<patrice.chotard-qxv4g6HH51o@public.gmane.org>, <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
	<kishon-l0cyMroinI0@public.gmane.org>, <arnd-r2nGTMty4D4@public.gmane.org>, <lee.jones-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <peter.griffin-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150111.185445.1288456704842706068.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi David,
On 01/12/2015 12:54 AM, David Miller wrote:
> From: Peter Griffin <peter.griffin-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> Date: Wed,  7 Jan 2015 15:04:05 +0000
>
>> A V2 of this old series incorporating Arnd and Lees Feedback form v1.
>>
>> Following on from Arnds comments about the picophy driver here
>> https://lkml.org/lkml/2014/11/13/161, this series fixes the
>> remaining upstreamed drivers for STI, which are mixing address spaces
>> in the reg property. We do this in a way similar to the keystone
>> and bcm7445 platforms, by having sysconfig phandle/ offset pair
>> (where only one register is required). Or phandle / integer array
>> where multiple offsets in the same bank are needed).
>>
>> This series breaks DT compatability! But the platform support
>> is WIP and only being used by the few developers who are upstreaming
>> support for it. I've made each change to the driver / dt doc / dt
>> file as a single atomic commit so the kernel will remain bisectable.
>>
>> This series then also enables the picophy driver, and adds back in
>> the ehci/ohci dt nodes for stih410 which make use of the picophy.
> Series applied to net-next, thanks.
Did you apply all the series to net-next?

I need the DT patches in STi SoC tree, that will go to Linus tree via 
arm-soc, hopefully for v3.20.

How could we synchronize?
Maybe I could create an immutable tag on top of STi DT branch, which is 
based on top of v3.19-rc1,
that you would merge in your tree?

Please let me know your preferred way.

Thanks,
Maxime

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
