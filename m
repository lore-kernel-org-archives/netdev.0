From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH v2 06/27] brcm80211: move under broadcom vendor directory
Date: Thu, 19 Nov 2015 09:48:59 +0200
Message-ID: <871tbmwhsk.fsf@kamboji.qca.qualcomm.com>
References: <1447857966-19560-1-git-send-email-kvalo@codeaurora.org>
	<1447857966-19560-7-git-send-email-kvalo@codeaurora.org>
	<564CCF2A.4030203@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Arend van Spriel <arend@broadcom.com>,
	brcm80211-dev-list@broadcom.com
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <564CCF2A.4030203@hauke-m.de> (Hauke Mehrtens's message of "Wed,
	18 Nov 2015 20:19:06 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hauke Mehrtens <hauke@hauke-m.de> writes:

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

I think this could be done separately. This patchset is big enough
already, I would not like to make it anymore complicated.

And I actually like the brcm80211 directory, I would not mind keeping it
still.

-- 
Kalle Valo
