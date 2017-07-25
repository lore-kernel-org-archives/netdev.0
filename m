From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] mwifiex: fix compile warning of unused variable
Date: Tue, 25 Jul 2017 15:33:31 +0300
Message-ID: <87vamgitlw.fsf@codeaurora.org>
References: <1499327433-70786-1-git-send-email-shawn.lin@rock-chips.com>
        <20170706171152.GA120202@google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shawn Lin <shawn.lin@rock-chips.com>,
        Amitkumar Karwar <amitkarwar@gmail.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Nishant Sarmukadam <nishants@marvell.com>,
        Xinming Hu <huxm@marvell.com>
To: Brian Norris <briannorris@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:41624 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750861AbdGYMdg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 08:33:36 -0400
In-Reply-To: <20170706171152.GA120202@google.com> (Brian Norris's message of
        "Thu, 6 Jul 2017 10:11:53 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Norris <briannorris@chromium.org> writes:

> On Thu, Jul 06, 2017 at 03:50:33PM +0800, Shawn Lin wrote:
>> We got a compile warning shows below:
>> 
>> drivers/net/wireless/marvell/mwifiex/sdio.c: In function
>> 'mwifiex_sdio_remove':
>> drivers/net/wireless/marvell/mwifiex/sdio.c:377:6: warning: variable
>> 'ret' set but not used [-Wunused-but-set-variable]
>
> It's probably worth noting that this is not a default warning [1],
> especially if you resend. It already confused Kalle.

Exactly, that way I can prioritise the patch accordingly. (W=1 warnings
are not that important so they go automatically to -next)

-- 
Kalle Valo
