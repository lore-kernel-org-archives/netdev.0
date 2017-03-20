From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [3/3] mwifiex: wake system up when receives a wake irq
Date: Mon, 20 Mar 2017 16:44:20 +0000 (UTC)
Message-ID: <20170320164421.2735E60DAF@smtp.codeaurora.org>
References: <1487917471-5501-3-git-send-email-jeffy.chen@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Amitkumar Karwar <akarwar@marvell.com>,
        Brian Norris <briannorris@chromium.org>,
        Rajat Jain <rajatja@google.com>,
        Jeffy Chen <jeffy.chen@rock-chips.com>, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
        Nishant Sarmukadam <nishants@marvell.com>
To: Jeffy Chen <jeffy.chen@rock-chips.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1487917471-5501-3-git-send-email-jeffy.chen@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeffy Chen <jeffy.chen@rock-chips.com> wrote:
> Currrently we are disabling this wake irq after receiving it. If this
> happens before we finish suspend and the pm event check is disabled,
> the system will continue suspending, and this irq would not work again.
> 
> We may need to abort system suspend to avoid that.
> 
> Signed-off-by: Jeffy Chen <jeffy.chen@rock-chips.com>

Patch applied to wireless-drivers-next.git, thanks.

ef7e07147425 mwifiex: wake system up when receives a wake irq

-- 
https://patchwork.kernel.org/patch/9589459/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
