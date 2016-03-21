From: Amitkumar Karwar <akarwar@marvell.com>
Subject: RE: [PATCH] mwifiex: advertise low priority scan feature
Date: Mon, 21 Mar 2016 08:26:36 +0000
Message-ID: <f865159f1eca4200aed1c4e4f272ae57@SC-EXCH04.marvell.com>
References: <1458547622-1632-1-git-send-email-wnhuang@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: LKML <linux-kernel@vger.kernel.org>,
	"djkurtz@chromium.org" <djkurtz@chromium.org>,
	Nishant Sarmukadam <nishants@marvell.com>,
	"kvalo@codeaurora.org" <kvalo@codeaurora.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Wei-Ning Huang <wnhuang@chromium.org>,
	Linux Wireless <linux-wireless@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016f401.pphosted.com ([67.231.156.173]:6327 "EHLO
	mx0b-0016f401.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751861AbcCUI0m convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Mar 2016 04:26:42 -0400
In-Reply-To: <1458547622-1632-1-git-send-email-wnhuang@google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: linux-wireless-owner@vger.kernel.org [mailto:linux-wireless-
> owner@vger.kernel.org] On Behalf Of Wei-Ning Huang
> Sent: Monday, March 21, 2016 1:37 PM
> To: Linux Wireless
> Cc: LKML; Amitkumar Karwar; djkurtz@chromium.org; Wei-Ning Huang;
> Nishant Sarmukadam; kvalo@codeaurora.org; netdev@vger.kernel.org
> Subject: [PATCH] mwifiex: advertise low priority scan feature
> 
> From: Amitkumar Karwar <akarwar@marvell.com>
> 
> Low priority scan handling code which delays or aborts scan operation
> based on Tx traffic is removed recently. The reason is firmware already
> takes care of it in our new feature scan channel gap. Hence we should
> advertise low priority scan support to cfg80211.
> 
> This patch fixes a problem in which OBSS scan request from
> wpa_supplicant was being rejected by cfg80211.
> 
> Signed-off-by: Wei-Ning Huang <wnhuang@chromium.org>
> ---
>  drivers/net/wireless/marvell/mwifiex/cfg80211.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/wireless/marvell/mwifiex/cfg80211.c
> b/drivers/net/wireless/marvell/mwifiex/cfg80211.c
> index bb7235e..7dafc5b 100644
> --- a/drivers/net/wireless/marvell/mwifiex/cfg80211.c
> +++ b/drivers/net/wireless/marvell/mwifiex/cfg80211.c
> @@ -4086,6 +4086,7 @@ int mwifiex_register_cfg80211(struct
> mwifiex_adapter *adapter)
> 
>  	wiphy->features |= NL80211_FEATURE_HT_IBSS |
>  			   NL80211_FEATURE_INACTIVITY_TIMER |
> +			   NL80211_FEATURE_LOW_PRIORITY_SCAN |
>  			   NL80211_FEATURE_NEED_OBSS_SCAN;
> 
>  	if (ISSUPP_TDLS_ENABLED(adapter->fw_cap_info))

Acked-by: Amitkumar Karwar <akarwar@marvell.com>

Regards,
Amitkumar
