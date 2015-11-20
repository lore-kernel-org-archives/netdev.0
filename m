From: Arend van Spriel <arend@broadcom.com>
Subject: Re: [PATCH v2 06/27] brcm80211: move under broadcom vendor directory
Date: Fri, 20 Nov 2015 22:51:29 +0100
Message-ID: <564F95E1.7030508@broadcom.com>
References: <1447857966-19560-1-git-send-email-kvalo@codeaurora.org>	<1447857966-19560-7-git-send-email-kvalo@codeaurora.org>	<564CCF2A.4030203@hauke-m.de> <564CCFC3.3030909@gmail.com> <87wptev2zi.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hauke Mehrtens <hauke@hauke-m.de>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <brcm80211-dev-list@broadcom.com>
To: Kalle Valo <kvalo@codeaurora.org>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:7976 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761013AbbKTVvd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 16:51:33 -0500
In-Reply-To: <87wptev2zi.fsf@kamboji.qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/19/2015 08:54 AM, Kalle Valo wrote:
> Florian Fainelli <f.fainelli@gmail.com> writes:
>
>> On 18/11/15 11:19, Hauke Mehrtens wrote:
>>> On 11/18/2015 03:45 PM, Kalle Valo wrote:
>>>> Part of reorganising wireless drivers directory and Kconfig. Note that I had to
>>>> edit Makefiles from subdirectories to use the new location.
>>>>
>>>> Signed-off-by: Kalle Valo <kvalo@codeaurora.org>
>>>> ---
>>>
>>> I would prefer to remove the brcm80211 directory in this process and create:
>>> drivers/net/wireless/broadcom/brcmfmac
>>> drivers/net/wireless/broadcom/brcmsmac
>>> drivers/net/wireless/broadcom/brcmutil
>>> drivers/net/wireless/broadcom/include
>>>
>>> This way we have one directory less.
>>
>> Would not that make keeping track of the previous and future history
>> harder for people contributing to these drivers? I could imagine that
>> for Arend and other Broadcom engineers, dealing with a simple level move
>> would be manageable, but having to account for a different directory
>> hierarchy could be a pain.
>>
>> What is the impact on compat-wireless after/before these changes by the way?
>
> It's called backports nowadays :)
>
> But I understood that as long as we have a separate kconfig option for
> the vendor directories (CONFIG_WLAN_VENDOR_*) it should be ok. For 4.3
> we didn't have that for realtek directory and that caused pain for
> backports.

That is my understanding as well.

Regards,
Arend
