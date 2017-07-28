From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: mwifiex: fix compile warning of unused variable
Date: Fri, 28 Jul 2017 14:50:02 +0000 (UTC)
Message-ID: <20170728145002.5F3C860128@smtp.codeaurora.org>
References: <1499327433-70786-1-git-send-email-shawn.lin@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Amitkumar Karwar <amitkarwar@gmail.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Nishant Sarmukadam <nishants@marvell.com>,
        Xinming Hu <huxm@marvell.com>,
        Shawn Lin <shawn.lin@rock-chips.com>
To: Shawn Lin <shawn.lin@rock-chips.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:49614 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751904AbdG1OuC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 10:50:02 -0400
In-Reply-To: <1499327433-70786-1-git-send-email-shawn.lin@rock-chips.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shawn Lin <shawn.lin@rock-chips.com> wrote:

> We got a compile warning shows below:
> 
> drivers/net/wireless/marvell/mwifiex/sdio.c: In function
> 'mwifiex_sdio_remove':
> drivers/net/wireless/marvell/mwifiex/sdio.c:377:6: warning: variable
> 'ret' set but not used [-Wunused-but-set-variable]
> 
> Per the code, it didn't check if mwifiex_sdio_read_fw_status
> finish successfully. We should at least check the return of
> mwifiex_sdio_read_fw_status, otherwise the following check of
> firmware_stat and adapter->mfg_mode is pointless as the device
> is probably dead.
> 
> Signed-off-by: Shawn Lin <shawn.lin@rock-chips.com>
> Reviewed-by: Brian Norris <briannorris@chromium.org>

Patch applied to wireless-drivers-next.git, thanks.

f46a5b0156b1 mwifiex: fix compile warning of unused variable

-- 
https://patchwork.kernel.org/patch/9827585/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
