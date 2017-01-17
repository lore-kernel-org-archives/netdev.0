From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: mwifiex: fix uninitialized variable access in pcie_remove
Date: Tue, 17 Jan 2017 11:55:36 +0000 (UTC)
Message-ID: <20170117115537.021FE605A3@smtp.codeaurora.org>
References: <20170113153534.2617372-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Amitkumar Karwar <akarwar@marvell.com>,
        Arnd Bergmann <arnd@arndb.de>,
        Nishant Sarmukadam <nishants@marvell.com>,
        Brian Norris <briannorris@chromium.org>,
        Xinming Hu <huxm@marvell.com>, Cathy Luo <cluo@marvell.com>,
        Shengzhen Li <szli@marvell.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170113153534.2617372-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd@arndb.de> wrote:
> Checking the firmware status from PCIe register only works
> if the register is available, otherwise we end up with
> random behavior:
> 
> drivers/net/wireless/marvell/mwifiex/pcie.c: In function 'mwifiex_pcie_remove':
> drivers/net/wireless/marvell/mwifiex/pcie.c:585:5: error: 'fw_status' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> This makes sure we treat the absence of the register as a failure.
> 
> Fixes: 045f0c1b5e26 ("mwifiex: get rid of global user_rmmod flag")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Patch applied to wireless-drivers-next.git, thanks.

0e8edb9aed03 mwifiex: fix uninitialized variable access in pcie_remove

-- 
https://patchwork.kernel.org/patch/9515899/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
