From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [v2,02/20] ath6kl: constify usb_device_id
Date: Fri, 11 Aug 2017 15:59:37 +0200
Message-ID: <e5102d3d94654b16b3c57455dd1c6991@euamsexm01a.eu.qualcomm.com>
References: <1502295823-20824-3-git-send-email-arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <kvalo@codeaurora.org>, <petkan@nucleusys.com>,
        <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-wireless@vger.kernel.org>
To: Arvind Yadav <arvind.yadav.cs@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502295823-20824-3-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arvind Yadav <arvind.yadav.cs@gmail.com> wrote:

> usb_device_id are not supposed to change at runtime. All functions
> working with usb_device_id provided by <linux/usb.h> work with
> const usb_device_id. So mark the non-const structs as const.
> 
> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
> Reviewed-by: Steve deRosier <derosier@gmail.com>
> Tested-by: Steve deRosier <derosier@gmail.com>
> Signed-off-by: Kalle Valo <kvalo@qca.qualcomm.com>

2 patches applied to ath-next branch of ath.git, thanks.

e881a6584941 ath6kl: constify usb_device_id
76b07b30c46b ath9k: constify usb_device_id

-- 
https://patchwork.kernel.org/patch/9890987/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
