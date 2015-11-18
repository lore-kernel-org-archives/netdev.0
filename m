From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 06/27] brcm80211: move under broadcom vendor directory
Date: Wed, 18 Nov 2015 11:21:39 -0800
Message-ID: <564CCFC3.3030909@gmail.com>
References: <1447857966-19560-1-git-send-email-kvalo@codeaurora.org> <1447857966-19560-7-git-send-email-kvalo@codeaurora.org> <564CCF2A.4030203@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Arend van Spriel <arend@broadcom.com>,
	brcm80211-dev-list@broadcom.com
To: Hauke Mehrtens <hauke@hauke-m.de>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:33266 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754512AbbKRTWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 14:22:42 -0500
In-Reply-To: <564CCF2A.4030203@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/11/15 11:19, Hauke Mehrtens wrote:
> On 11/18/2015 03:45 PM, Kalle Valo wrote:
>> Part of reorganising wireless drivers directory and Kconfig. Note that I had to
>> edit Makefiles from subdirectories to use the new location.
>>
>> Signed-off-by: Kalle Valo <kvalo@codeaurora.org>
>> ---
> 
> I would prefer to remove the brcm80211 directory in this process and create:
> drivers/net/wireless/broadcom/brcmfmac
> drivers/net/wireless/broadcom/brcmsmac
> drivers/net/wireless/broadcom/brcmutil
> drivers/net/wireless/broadcom/include
> 
> This way we have one directory less.

Would not that make keeping track of the previous and future history
harder for people contributing to these drivers? I could imagine that
for Arend and other Broadcom engineers, dealing with a simple level move
would be manageable, but having to account for a different directory
hierarchy could be a pain.

What is the impact on compat-wireless after/before these changes by the way?
-- 
Florian
