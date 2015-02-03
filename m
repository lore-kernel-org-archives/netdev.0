From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] brcmfmac: avoid duplicated suspend/resume operation
Date: Tue, 03 Feb 2015 15:08:07 +0200
Message-ID: <87vbjjw3bc.fsf@kamboji.qca.qualcomm.com>
References: <54C5AA8C.4010005@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: brudley@broadcom.com, Arend van Spriel <arend@broadcom.com>,
	Franky Lin <frankyl@broadcom.com>, meuleman@broadcom.com,
	linville@tuxdriver.com, pieterpg@broadcom.com, hdegoede@redhat.com,
	wens@csie.org, linux-wireless@vger.kernel.org,
	brcm80211-dev-list@broadcom.com, netdev@vger.kernel.org,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Fu\, Zhonghui" <zhonghui.fu@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54C5AA8C.4010005@linux.intel.com> (Zhonghui Fu's message of
	"Mon, 26 Jan 2015 10:46:36 +0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Fu, Zhonghui" <zhonghui.fu@linux.intel.com> writes:

>>From ff39ed4af9f1c50358fe92ec4c8eaac9db183e00 Mon Sep 17 00:00:00 2001
> From: Zhonghui Fu <zhonghui.fu@linux.intel.com>
> Date: Mon, 26 Jan 2015 10:13:21 +0800
> Subject: [PATCH] brcmfmac: avoid duplicated suspend/resume operation
>
> WiFi chip has 2 SDIO functions, and PM core will trigger
> twice suspend/resume operations for one WiFi chip to do
> the same things. This patch avoid this case.
>
> Acked-by: Arend van Spriel<arend@broadcom.com>
> Signed-off-by: Zhonghui Fu <zhonghui.fu@linux.intel.com>

This doesn't apply:

Applying: brcmfmac: avoid duplicated suspend/resume operation
Using index info to reconstruct a base tree...
Falling back to patching base and 3-way merge...
Auto-merging drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
CONFLICT (content): Merge conflict in drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
Failed to merge in the changes.
Patch failed at 0001 brcmfmac: avoid duplicated suspend/resume operation

BTW, when you resend a patch please use "[PATCH v2]" (or v3, v4...) in
the Subject field.

-- 
Kalle Valo
