From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [1/3] net: rtlwifi: constify rate_control_ops
Date: Thu, 24 Aug 2017 09:57:48 +0000 (UTC)
Message-ID: <20170824095748.41364606B7@smtp.codeaurora.org>
References: <1503482375-19983-2-git-send-email-arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Larry.Finger@lwfinger.net,
        chaoming_li@realsil.com.cn, jon.maloy@ericsson.com,
        ying.xue@windriver.com, linux-kernel@vger.kernel.org,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Arvind Yadav <arvind.yadav.cs@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503482375-19983-2-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arvind Yadav <arvind.yadav.cs@gmail.com> wrote:

> rate_control_ops are not supposed to change at runtime. All functions
> working with rate_control_ops provided by <net/mac80211.h> work with
> const rate_control_ops. So mark the non-const structs as const.
> 
> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>

2 patches applied to wireless-drivers-next.git, thanks.

28b75415ad19 wireless: ipw2200: Replace PCI pool old API
9ea792a48cdd net: rsi: mac80211: constify ieee80211_ops

-- 
https://patchwork.kernel.org/patch/9917001/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
