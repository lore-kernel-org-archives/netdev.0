From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] rsi: add in missing RSI_FSM_STATES into array fsm_state
Date: Wed, 28 Jun 2017 19:22:02 +0300
Message-ID: <87vangqdzp.fsf@kamboji.qca.qualcomm.com>
References: <20170622165804.24379-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:40694 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751579AbdF1QWI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 12:22:08 -0400
In-Reply-To: <20170622165804.24379-1-colin.king@canonical.com> (Colin King's
        message of "Thu, 22 Jun 2017 17:58:04 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Colin King <colin.king@canonical.com> writes:

> From: Colin Ian King <colin.king@canonical.com>
>
> Two recent commits added new RSI_FSM_STATES (namely FSM_FW_NOT_LOADED
> and FSM_COMMON_DEV_PARAMS_SENT) and the corresponding table fsm_state
> was not updated to match. This can lead to an array overrun when
> accessing the latter two states in fsm_state. Fix this by adding in
> the missing states.
>
> Detected by CoverityScan, CID#1398379 ("Illegal address computation")
>
> Fixes: 9920322ccd8e04 ("rsi: add tx frame for common device configuration")
> Fixes: 015e367494c1d5 ("rsi: Register interrupt handler before firmware load")

This is very much nitpicking, no need to resend because of this, but the
preferred format is to to use 12 chars for the commit id:

Fixes: 9920322ccd8e ("rsi: add tx frame for common device configuration")
Fixes: 015e367494c1 ("rsi: Register interrupt handler before firmware load")

Documentation/process/submitting-patches.rst contains a nice tip how you
can get that automatically with git:

        [core]
                abbrev = 12
        [pretty]
                fixes = Fixes: %h (\"%s\")

-- 
Kalle Valo
