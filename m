From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [11/11] brcmfmac: constify pci_device_id
Date: Fri, 28 Jul 2017 15:04:01 +0000 (UTC)
Message-ID: <20170728150401.C25B360A18@smtp.codeaurora.org>
References: <1500315402-3439-1-git-send-email-arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: arend.vanspriel@broadcom.com, hante.meuleman@broadcom.com,
        franky.lin@broadcom.com, wright.feng@cypress.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com, brcm80211-dev-list@cypress.com
To: Arvind Yadav <arvind.yadav.cs@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1500315402-3439-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arvind Yadav <arvind.yadav.cs@gmail.com> wrote:

> pci_device_id are not supposed to change at runtime. All functions
> working with pci_device_id provided by <linux/pci.h> work with
> const pci_device_id. So mark the non-const structs as const.
> 
> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
> Acked-by: Arend van Spriel <arend.vanspriel@broadcom.com>

Patch applied to wireless-drivers-next.git, thanks.

e66d70b789d1 brcmfmac: constify pci_device_id

-- 
https://patchwork.kernel.org/patch/9845919/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
