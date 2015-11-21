From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: Re: [PATCH v2 06/27] brcm80211: move under broadcom vendor directory
Date: Sat, 21 Nov 2015 14:46:13 +0100
Message-ID: <565075A5.4020506@hauke-m.de>
References: <1447857966-19560-1-git-send-email-kvalo@codeaurora.org>
 <1447857966-19560-7-git-send-email-kvalo@codeaurora.org>
 <564CCF2A.4030203@hauke-m.de> <871tbmwhsk.fsf@kamboji.qca.qualcomm.com>
 <564F966A.7080300@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, brcm80211-dev-list@broadcom.com
To: Arend van Spriel <arend@broadcom.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hauke-m.de ([5.39.93.123]:40140 "EHLO hauke-m.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751449AbbKUNqQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Nov 2015 08:46:16 -0500
In-Reply-To: <564F966A.7080300@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/20/2015 10:53 PM, Arend van Spriel wrote:
> On 11/19/2015 08:48 AM, Kalle Valo wrote:
>> Hauke Mehrtens <hauke@hauke-m.de> writes:
>>
>>> On 11/18/2015 03:45 PM, Kalle Valo wrote:
>>>> Part of reorganising wireless drivers directory and Kconfig. Note
>>>> that I had to
>>>> edit Makefiles from subdirectories to use the new location.
>>>>
>>>> Signed-off-by: Kalle Valo <kvalo@codeaurora.org>
>>>> ---
>>>
>>> I would prefer to remove the brcm80211 directory in this process and
>>> create:
>>> drivers/net/wireless/broadcom/brcmfmac
>>> drivers/net/wireless/broadcom/brcmsmac
>>> drivers/net/wireless/broadcom/brcmutil
>>> drivers/net/wireless/broadcom/include
>>>
>>> This way we have one directory less.
>>
>> I think this could be done separately. This patchset is big enough
>> already, I would not like to make it anymore complicated.
>>
>> And I actually like the brcm80211 directory, I would not mind keeping it
>> still.
> 
> I prefer to keep it as brcmsmac and brcmfmac rely on brcmutil module so
> I want to keep them together under brcm80211.
> 
> So does this patch go in before or after the patches I submitted before
> the merge window. I hope after :-p

Ok, then leave it like Kalle proposed. backports should work with both
versions.

Hauke
