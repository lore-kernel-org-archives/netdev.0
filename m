From: Brian Norris <briannorris@chromium.org>
Subject: Re: [PATCH v2] mwifiex: uninit wakeup info in the error handling
Date: Thu, 6 Jul 2017 10:15:58 -0700
Message-ID: <20170706171557.GA121983@google.com>
References: <1499327728-25388-1-git-send-email-jeffy.chen@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, akarwar@marvell.com,
        Xinming Hu <huxm@marvell.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Ganapathi Bhat <gbhat@marvell.com>,
        Amitkumar Karwar <amitkarwar@gmail.com>,
        linux-kernel@vger.kernel.org,
        Nishant Sarmukadam <nishants@marvell.com>,
        netdev@vger.kernel.org
To: Jeffy Chen <jeffy.chen@rock-chips.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1499327728-25388-1-git-send-email-jeffy.chen@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 06, 2017 at 03:55:28PM +0800, Jeffy Chen wrote:
> We inited wakeup info at the beginning of mwifiex_add_card, so we need
> to uninit it in the error handling.
> 
> It's much the same as what we did in:
> 36908c4 mwifiex: uninit wakeup info when removing device
> 
> Signed-off-by: Jeffy Chen <jeffy.chen@rock-chips.com>
> 
> ---
> 
> Changes in v2:
> Uninit wakeup when _mwifiex_fw_dpc failed too.

Looks good to me:

Reviewed-by: Brian Norris <briannorris@chromium.org>
