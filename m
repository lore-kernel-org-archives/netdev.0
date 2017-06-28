From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: rsi: add in missing RSI_FSM_STATES into array fsm_state
Date: Wed, 28 Jun 2017 17:54:29 +0000 (UTC)
Message-ID: <20170628175429.3F57760B7F@smtp.codeaurora.org>
References: <20170622165804.24379-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Colin Ian King <colin.king@canonical.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin Ian King <colin.king@canonical.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170622165804.24379-1-colin.king@canonical.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Colin Ian King <colin.king@canonical.com> wrote:

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
> Fixes: 9920322ccd8e ("rsi: add tx frame for common device configuration")
> Fixes: 015e367494c1 ("rsi: Register interrupt handler before firmware load")
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Patch applied to wireless-drivers-next.git, thanks.

58828680af49 rsi: add in missing RSI_FSM_STATES into array fsm_state

-- 
https://patchwork.kernel.org/patch/9804857/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches

