From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [v3,04/10] ipw2200: constify attribute_group structures
Date: Fri, 28 Jul 2017 15:06:11 +0000 (UTC)
Message-ID: <20170728150611.96B1A60884@smtp.codeaurora.org>
References: <1500371102-14758-1-git-send-email-arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, stas.yakovlev@gmail.com, sgruszka@redhat.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-wireless@vger.kernel.org
To: Arvind Yadav <arvind.yadav.cs@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1500371102-14758-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arvind Yadav <arvind.yadav.cs@gmail.com> wrote:

> attribute_group are not supposed to change at runtime. All functions
> working with attribute_group provided by <linux/sysfs.h> work
> with const attribute_group. So mark the non-const structs as const.
> 
> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>

4 patches applied to wireless-drivers-next.git, thanks.

17830147c40a mwifiex: fix spelling mistake: "Insuffient" -> "Insufficient"
185ffc194800 ipw2100: don't return positive values to PCI probe on error
af643fe9bbe0 zd1211rw: fix spelling mistake 'hybernate' -> 'hibernate'
e66d70b789d1 brcmfmac: constify pci_device_id

-- 
https://patchwork.kernel.org/patch/9847373/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
