From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: wlcore: fix 64K page support
Date: Wed, 24 May 2017 13:42:57 +0000 (UTC)
Message-ID: <20170524134257.AB8C361155@smtp.codeaurora.org>
References: <20170511115307.3060650-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, stable@vger.kernel.org,
        "Reizer, Eyal" <eyalr@ti.com>, Tony Lindgren <tony@atomide.com>,
        Wei Yongjun <weiyj.lk@gmail.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170511115307.3060650-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd@arndb.de> wrote:
> In the stable linux-3.16 branch, I ran into a warning in the
> wlcore driver:
> 
> drivers/net/wireless/ti/wlcore/spi.c: In function 'wl12xx_spi_raw_write':
> drivers/net/wireless/ti/wlcore/spi.c:315:1: error: the frame size of 12848 bytes is larger than 2048 bytes [-Werror=frame-larger-than=]
> 
> Newer kernels no longer show the warning, but the bug is still there,
> as the allocation is based on the CPU page size rather than the
> actual capabilities of the hardware.
> 
> This replaces the PAGE_SIZE macro with the SZ_4K macro, i.e. 4096 bytes
> per buffer.
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Patch applied to wireless-drivers-next.git, thanks.

4a4274bf2dbb wlcore: fix 64K page support

-- 
https://patchwork.kernel.org/patch/9721269/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
