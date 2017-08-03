From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [10/11] net: qtnfmac: constify pci_device_id.
Date: Thu,  3 Aug 2017 10:10:31 +0000 (UTC)
Message-ID: <20170803101031.6BEBA607B6@smtp.codeaurora.org>
References: <1500315263-3373-1-git-send-email-arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: imitsyanko@quantenna.com, avinashp@quantenna.com,
        smatyukevich@quantenna.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org
To: Arvind Yadav <arvind.yadav.cs@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1500315263-3373-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arvind Yadav <arvind.yadav.cs@gmail.com> wrote:

> pci_device_id are not supposed to change at runtime. All functions
> working with pci_device_id provided by <linux/pci.h> work with
> const pci_device_id. So mark the non-const structs as const.
> 
> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
> Reviewed-by: Sergey Matyukevich <sergey.matyukevich.os@quantenna.com>

Patch applied to wireless-drivers-next.git, thanks.

cc5becd38e87 net: qtnfmac: constify pci_device_id.

-- 
https://patchwork.kernel.org/patch/9845911/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
