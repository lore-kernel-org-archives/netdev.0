From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [-next] rtlwifi: kfree entry until after entry->bssid has been
 accessed
Date: Thu, 27 Jul 2017 10:58:35 +0000 (UTC)
Message-ID: <20170727105836.02AB5607C8@smtp.codeaurora.org>
References: <20170630100843.9188-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin Ian King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170630100843.9188-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Colin Ian King <colin.king@canonical.com> wrote:

> From: Colin Ian King <colin.king@canonical.com>
> 
> The current code kfree's entry and then dereferences it by accessing
> entry->bssid.  Avoid the dereference-after-free by moving the kfree
> after the access to entry->bssid.
> 
> Detected by CoverityScan, CID#1448600 ("Read from pointer after free")
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Patch applied to wireless-drivers-next.git, thanks.

d0116f6f7b30 rtlwifi: kfree entry until after entry->bssid has been accessed

-- 
https://patchwork.kernel.org/patch/9819083/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
