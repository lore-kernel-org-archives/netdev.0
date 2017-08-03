From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [01/11] rtlwifi: rtl8192de: constify pci_device_id.
Date: Thu,  3 Aug 2017 10:06:46 +0000 (UTC)
Message-ID: <20170803100647.2B7CA606DC@smtp.codeaurora.org>
References: <1500314995-3181-2-git-send-email-arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Larry.Finger@lwfinger.net, chaoming_li@realsil.com.cn,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Arvind Yadav <arvind.yadav.cs@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1500314995-3181-2-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arvind Yadav <arvind.yadav.cs@gmail.com> wrote:

> pci_device_id are not supposed to change at runtime. All functions
> working with pci_device_id provided by <linux/pci.h> work with
> const pci_device_id. So mark the non-const structs as const.
> 
> File size before:
>    text	   data	    bss	    dec	    hex	filename
>    2833	    945	     12	   3790	    ece realtek/rtlwifi/rtl8192de/sw.o
> 
> File size After adding 'const':
>    text	   data	    bss	    dec	    hex	filename
>    2929	    849	     12	   3790	    ece realtek/rtlwifi/rtl8192de/sw.o
> 
> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
> Acked-by: Larry Finger <Larry.Finger@lwfinger.net>

7 patches applied to wireless-drivers-next.git, thanks.

d86d8dbdebcc rtlwifi: rtl8192de: constify pci_device_id.
67f512e6707f rtlwifi: rtl8192se: constify pci_device_id.
468952f14714 rtlwifi: rtl8821ae: constify pci_device_id.
e9a214def6ce rtlwifi: rtl8723ae: constify pci_device_id.
8c6f0f5bf1e1 rtlwifi: rtl8723be: constify pci_device_id.
4dc2efc132a7 rtlwifi: rtl8188ee: constify pci_device_id.
d20d893d7a74 rtlwifi: rtl8192ee: constify pci_device_id.

-- 
https://patchwork.kernel.org/patch/9845899/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
