From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v3] brcmfmac: add missing header dependencies
Date: Mon, 29 Aug 2016 11:02:07 +0200
Message-ID: <6640253.GDmR9LxZA8@wuerfel>
References: <1472458485-24499-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: franky.lin@broadcom.com, hante.meuleman@broadcom.com,
        kvalo@codeaurora.org, linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, xie.baoyou@zte.com.cn
To: Baoyou Xie <baoyou.xie@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472458485-24499-1-git-send-email-baoyou.xie@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, August 29, 2016 4:14:45 PM CEST Baoyou Xie wrote:
> We get 1 warning when biuld kernel with W=1:
> drivers/net/wireless/broadcom/brcm80211/brcmfmac/tracepoint.c:23:6: warning: no previous prototype for '__brcmf_err' [-Wmissing-prototypes]
> 
> In fact, this function is declared in brcmfmac/debug.h, so this patch
> add missing header dependencies.
> 
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>

Acked-by: Arnd Bergmann <arnd@arndb.de>
