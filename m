From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: mwifiex: MAC randomization should not be persistent
Date: Thu, 20 Apr 2017 07:17:24 +0000 (UTC)
Message-ID: <20170420071724.6D77E60FFC@smtp.codeaurora.org>
References: <20170405222640.4494-1-briannorris@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Nishant Sarmukadam <nishants@marvell.com>,
        Ganapathi Bhat <gbhat@marvell.com>,
        Xinming Hu <huxm@marvell.com>, <linux-kernel@vger.kernel.org>,
        Dmitry Torokhov <dmitry.torokhov@gmail.com>,
        netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
        Brian Norris <briannorris@chromium.org>
To: Brian Norris <briannorris@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:58942 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S940033AbdDTHRZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 03:17:25 -0400
In-Reply-To: <20170405222640.4494-1-briannorris@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Norris <briannorris@chromium.org> wrote:
> nl80211 provides the NL80211_SCAN_FLAG_RANDOM_ADDR for every scan
> request that should be randomized; the absence of such a flag means we
> should not randomize. However, mwifiex was stashing the latest
> randomization request and *always* using it for future scans, even those
> that didn't set the flag.
> 
> Let's zero out the randomization info whenever we get a scan request
> without NL80211_SCAN_FLAG_RANDOM_ADDR. I'd prefer to remove
> priv->random_mac entirely (and plumb the randomization MAC properly
> through the call sequence), but the spaghetti is a little difficult to
> unravel here for me.
> 
> Fixes: c2a8f0ff9c6c ("mwifiex: support random MAC address for scanning")
> Cc: <stable@vger.kernel.org> # 4.9+
> Signed-off-by: Brian Norris <briannorris@chromium.org>

Patch applied to wireless-drivers-next.git, thanks.

7e2f18f06408 mwifiex: MAC randomization should not be persistent

-- 
https://patchwork.kernel.org/patch/9665813/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
