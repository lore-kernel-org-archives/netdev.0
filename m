From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 4/7] rtlwifi: Remove unused RTL_SUPPORTED_CTRL_FILTER
 define
Date: Fri, 30 Jan 2015 10:06:44 -0600
Message-ID: <54CBAC14.5060502@lwfinger.net>
References: <1422341373-22196-1-git-send-email-plaes@plaes.org> <1422341373-22196-4-git-send-email-plaes@plaes.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Priit Laes <plaes@plaes.org>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422341373-22196-4-git-send-email-plaes@plaes.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/27/2015 12:49 AM, Priit Laes wrote:
> Signed-off-by: Priit Laes <plaes@plaes.org>
> ---
>   drivers/net/wireless/rtlwifi/core.h | 2 --
>   1 file changed, 2 deletions(-)
>
> diff --git a/drivers/net/wireless/rtlwifi/core.h b/drivers/net/wireless/rtlwifi/core.h
> index 624e1dc..3b37557 100644
> --- a/drivers/net/wireless/rtlwifi/core.h
> +++ b/drivers/net/wireless/rtlwifi/core.h
> @@ -33,8 +33,6 @@
>   	FIF_FCSFAIL | \
>   	FIF_BCN_PRBRESP_PROMISC)
>
> -#define RTL_SUPPORTED_CTRL_FILTER	0xFF
> -
>   extern const struct ieee80211_ops rtl_ops;
>   void rtl_fw_cb(const struct firmware *firmware, void *context);
>   void rtl_addr_delay(u32 addr);

Priit,

I have a couple of points to make. First, when you submit a series of patches 
like this, it is customary to use the cover letter feature of git to generate a 
0/X patch in which to explain the set of patches. In this case, the cover letter 
is not necessary, but it is a good habit to cultivate.

The second point is more important. I'm not sure what source you used to 
generate your patches, but it was clearly not wireless-drivers-next. Commit 
6f8214b69057 ("rtlwifi: Create new routine to initialize the DM tables") moved a 
lot of stuff from the individual drivers into the core. Some of the new stuff 
was included right after the definition of RTL_SUPPORTED_CTRL_FILTER, thus your 
patch fails to apply.

Once you fix this problem, and resubmit V2 of the series, I will approve them. 
FYI, Kalle prefers that all patches be resubmitted, not just the one that changes.


Larry
