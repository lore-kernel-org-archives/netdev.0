From: "Fu, Zhonghui" <zhonghui.fu@linux.intel.com>
Subject: Re: [PATCH] brcmfmac: avoid duplicated suspend/resume operation
Date: Thu, 05 Feb 2015 19:56:38 +0800
Message-ID: <54D35A76.4010801@linux.intel.com>
References: <54C5AA8C.4010005@linux.intel.com> <87vbjjw3bc.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: brudley@broadcom.com, Arend van Spriel <arend@broadcom.com>,
	Franky Lin <frankyl@broadcom.com>, meuleman@broadcom.com,
	linville@tuxdriver.com, pieterpg@broadcom.com, hdegoede@redhat.com,
	wens@csie.org, linux-wireless@vger.kernel.org,
	brcm80211-dev-list@broadcom.com, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87vbjjw3bc.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 2015/2/3 21:08, Kalle Valo wrote:
> "Fu, Zhonghui" <zhonghui.fu@linux.intel.com> writes:
>
>> >From ff39ed4af9f1c50358fe92ec4c8eaac9db183e00 Mon Sep 17 00:00:00 2001
>> From: Zhonghui Fu <zhonghui.fu@linux.intel.com>
>> Date: Mon, 26 Jan 2015 10:13:21 +0800
>> Subject: [PATCH] brcmfmac: avoid duplicated suspend/resume operation
>>
>> WiFi chip has 2 SDIO functions, and PM core will trigger
>> twice suspend/resume operations for one WiFi chip to do
>> the same things. This patch avoid this case.
>>
>> Acked-by: Arend van Spriel<arend@broadcom.com>
>> Signed-off-by: Zhonghui Fu <zhonghui.fu@linux.intel.com>
> This doesn't apply:
>
> Applying: brcmfmac: avoid duplicated suspend/resume operation
> Using index info to reconstruct a base tree...
> Falling back to patching base and 3-way merge...
> Auto-merging drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
> CONFLICT (content): Merge conflict in drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
> Failed to merge in the changes.
> Patch failed at 0001 brcmfmac: avoid duplicated suspend/resume operation
>
> BTW, when you resend a patch please use "[PATCH v2]" (or v3, v4...) in
> the Subject field.
Just see your comments, so please ignore my inquiry in last mail. I will re-base this patch again.


Thanks,
Zhonghui
