From: Arend van Spriel <arend@broadcom.com>
Subject: Re: [PATCH v2 06/27] brcm80211: move under broadcom vendor directory
Date: Fri, 20 Nov 2015 22:53:46 +0100
Message-ID: <564F966A.7080300@broadcom.com>
References: <1447857966-19560-1-git-send-email-kvalo@codeaurora.org>	<1447857966-19560-7-git-send-email-kvalo@codeaurora.org>	<564CCF2A.4030203@hauke-m.de> <871tbmwhsk.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <brcm80211-dev-list@broadcom.com>
To: Kalle Valo <kvalo@codeaurora.org>,
	Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <871tbmwhsk.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/19/2015 08:48 AM, Kalle Valo wrote:
> Hauke Mehrtens <hauke@hauke-m.de> writes:
>
>> On 11/18/2015 03:45 PM, Kalle Valo wrote:
>>> Part of reorganising wireless drivers directory and Kconfig. Note that I had to
>>> edit Makefiles from subdirectories to use the new location.
>>>
>>> Signed-off-by: Kalle Valo <kvalo@codeaurora.org>
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
> I think this could be done separately. This patchset is big enough
> already, I would not like to make it anymore complicated.
>
> And I actually like the brcm80211 directory, I would not mind keeping it
> still.

I prefer to keep it as brcmsmac and brcmfmac rely on brcmutil module so 
I want to keep them together under brcm80211.

So does this patch go in before or after the patches I submitted before 
the merge window. I hope after :-p

Regards,
Arend
