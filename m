From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] mwifiex: fix compile warning of unused variable
Date: Thu, 06 Jul 2017 10:57:14 +0300
Message-ID: <87k23mf15x.fsf@kamboji.qca.qualcomm.com>
References: <1499327433-70786-1-git-send-email-shawn.lin@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Amitkumar Karwar <amitkarwar@gmail.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Nishant Sarmukadam <nishants@marvell.com>,
        Xinming Hu <huxm@marvell.com>
To: Shawn Lin <shawn.lin@rock-chips.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:39294 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751741AbdGFH5l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2017 03:57:41 -0400
In-Reply-To: <1499327433-70786-1-git-send-email-shawn.lin@rock-chips.com>
        (Shawn Lin's message of "Thu, 6 Jul 2017 15:50:33 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shawn Lin <shawn.lin@rock-chips.com> writes:

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

I don't see that warning, any ideas why? My compiler:

gcc (Ubuntu 5.4.0-6ubuntu1~16.04.4) 5.4.0 20160609


-- 
Kalle Valo
