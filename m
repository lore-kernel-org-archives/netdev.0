From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 00/35] constify net usb_device_id
Date: Tue, 08 Aug 2017 21:36:29 +0300
Message-ID: <87mv79j49e.fsf@kamboji.qca.qualcomm.com>
References: <1502207730-11404-1-git-send-email-arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: wg@grandegger.com, mkl@pengutronix.de, linux-can@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arvind Yadav <arvind.yadav.cs@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502207730-11404-1-git-send-email-arvind.yadav.cs@gmail.com>
        (Arvind Yadav's message of "Tue, 8 Aug 2017 21:25:27 +0530")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arvind Yadav <arvind.yadav.cs@gmail.com> writes:

> usb_device_id are not supposed to change at runtime. All functions
> working with usb_device_id provided by <linux/usb.h> work with
> const usb_device_id. So mark the non-const structs as const.

[...]

>   [PATCH 16/35] wireless: ath: ar5523: constify usb_device_id
>   [PATCH 17/35] wireless: ath: ath6kl: constify usb_device_id
>   [PATCH 18/35] wireless: ath: ath9k: constify usb_device_id
>   [PATCH 19/35] wireless: ath: carl9170: constify usb_device_id
>   [PATCH 20/35] wireless: atmel: at76c50x: constify usb_device_id
>   [PATCH 21/35] wireless: broadcom: brcm80211: constify usb_device_id
>   [PATCH 22/35] wireless: intersil: orinoco: constify usb_device_id
>   [PATCH 23/35] wireless: intersil: p54: constify usb_device_id
>   [PATCH 24/35] wireless: marvell: libertas: constify usb_device_id
>   [PATCH 25/35] wireless: marvell: libertas_tf: constify usb_device_id
>   [PATCH 26/35] wireless: marvell: mwifiex: constify usb_device_id
>   [PATCH 27/35] wireless: mediatek: mt7601u: constify usb_device_id
>   [PATCH 28/35] wireless: ralink: rt2500usb: constify usb_device_id
>   [PATCH 29/35] wireless: ralink: rt2800usb: constify usb_device_id
>   [PATCH 30/35] wireless: ralink: rt73usb: constify usb_device_id
>   [PATCH 31/35] wireless: realtek: rtl8187: constify usb_device_id
>   [PATCH 32/35] wireless: realtek: rtl8xxxu: constify usb_device_id
>   [PATCH 33/35] wireless: realtek: rtl8192cu: constify usb_device_id
>   [PATCH 34/35] wireless: zydas: zd1201: constify usb_device_id
>   [PATCH 35/35] wireless: zydas: zd1211rw: constify usb_device_id

No need to put the whole path to the title, it's enough to have the name
of the driver there. For example:

[PATCH 16/35] ar5523: constify usb_device_id
[PATCH 17/35] ath6kl: constify usb_device_id
[PATCH 18/35] ath9k: constify usb_device_id

Please resubmit the wireless patches separately in their own patchset.

-- 
Kalle Valo
