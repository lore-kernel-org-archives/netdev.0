From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [v3] mwifiex: report wakeup for wowlan
Date: Thu, 17 Nov 2016 06:41:20 +0000 (UTC)
Message-ID: <20161117064120.5925C61414@smtp.codeaurora.org>
References: <1475613462-93384-1-git-send-email-rajatja@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Amitkumar Karwar <akarwar@marvell.com>,
        Nishant Sarmukadam <nishants@marvell.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Rajat Jain <rajatja@google.com>,
        Wei-Ning Huang <wnhuang@google.com>,
        Brian Norris <briannorris@google.com>,
        Eric Caruso <ejcaruso@chromium.org>, rajatxjain@gmail.com
To: Rajat Jain <rajatja@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:42642 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938562AbcKQGlV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 01:41:21 -0500
In-Reply-To: <1475613462-93384-1-git-send-email-rajatja@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rajat Jain <rajatja@google.com> wrote:
> Register the WLAN device as a wakeup source since it can
> wake the system via wake-on-wireless-lan. In an actual wowlan
> event, notify the PM core that we are the current wakeup source.
> This allows the PM core to update the wakeup attributes in /sys.
> 
> This was causing wakeup issues on chromeos as the system was
> apparently confused about the wakeup source.
> 
> Signed-off-by: Wei-Ning Huang <wnhuang@google.com>
> Signed-off-by: Rajat Jain <rajatja@google.com>
> Tested-by: Wei-Ning Huang <wnhuang@chromium.org>
> Reviewed-by: Eric Caruso <ejcaruso@chromium.org>
> Acked-by: Amitkumar Karwar <akarwar@marvell.com>

Patch applied to wireless-drivers-next.git, thanks.

df566a481ee8 mwifiex: report wakeup for wowlan

-- 
https://patchwork.kernel.org/patch/9362275/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
