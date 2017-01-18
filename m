From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [1/1] net: wireless: marvell: fix improper return value
Date: Wed, 18 Jan 2017 14:43:46 +0000 (UTC)
Message-ID: <20170118144346.8E91760818@smtp.codeaurora.org>
References: <1480760857-4549-1-git-send-email-bianpan2016@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Andreas Kemnade <andreas@kemnade.info>,
        Johannes Berg <johannes.berg@intel.com>,
        libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Pan Bian <bianpan2016@163.com>
To: Pan Bian <bianpan2016@163.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480760857-4549-1-git-send-email-bianpan2016@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pan Bian <bianpan2016@163.com> wrote:
> Function lbs_cmd_802_11_sleep_params() always return 0, even if the call
> to lbs_cmd_with_response() fails. In this case, the parameter @sp will
> keep uninitialized. Because the return value is 0, its caller (say
> lbs_sleepparams_read()) will not detect the error, and will copy the
> uninitialized stack memory to user sapce, resulting in stack information
> leak. To avoid the bug, this patch returns variable ret (which takes
> the return value of lbs_cmd_with_response()) instead of 0.
> 
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=188451
> 
> Signed-off-by: Pan Bian <bianpan2016@163.com>

The prefix should be "libertas:", I'll fix that.

-- 
https://patchwork.kernel.org/patch/9459597/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
