From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH v2 06/27] brcm80211: move under broadcom vendor directory
Date: Thu, 19 Nov 2015 09:54:09 +0200
Message-ID: <87wptev2zi.fsf@kamboji.qca.qualcomm.com>
References: <1447857966-19560-1-git-send-email-kvalo@codeaurora.org>
	<1447857966-19560-7-git-send-email-kvalo@codeaurora.org>
	<564CCF2A.4030203@hauke-m.de> <564CCFC3.3030909@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hauke Mehrtens <hauke-5/S+JYg5SzeELgA04lAiVw@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <564CCFC3.3030909-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (Florian Fainelli's message of "Wed,
	18 Nov 2015 11:21:39 -0800")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> On 18/11/15 11:19, Hauke Mehrtens wrote:
>> On 11/18/2015 03:45 PM, Kalle Valo wrote:
>>> Part of reorganising wireless drivers directory and Kconfig. Note that I had to
>>> edit Makefiles from subdirectories to use the new location.
>>>
>>> Signed-off-by: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
>>> ---
>> 
>> I would prefer to remove the brcm80211 directory in this process and create:
>> drivers/net/wireless/broadcom/brcmfmac
>> drivers/net/wireless/broadcom/brcmsmac
>> drivers/net/wireless/broadcom/brcmutil
>> drivers/net/wireless/broadcom/include
>> 
>> This way we have one directory less.
>
> Would not that make keeping track of the previous and future history
> harder for people contributing to these drivers? I could imagine that
> for Arend and other Broadcom engineers, dealing with a simple level move
> would be manageable, but having to account for a different directory
> hierarchy could be a pain.
>
> What is the impact on compat-wireless after/before these changes by the way?

It's called backports nowadays :)

But I understood that as long as we have a separate kconfig option for
the vendor directories (CONFIG_WLAN_VENDOR_*) it should be ok. For 4.3
we didn't have that for realtek directory and that caused pain for
backports.

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
