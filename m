From: Amitkumar Karwar <akarwar@marvell.com>
Subject: RE: [PATCH 0/8] mwifiex: Fix some error handling issues in
 mwifiex_sdio_probe() function
Date: Thu, 9 Jun 2016 13:43:32 +0000
Message-ID: <4e8cc9d4a8db4283aaa38564b6a36556@SC-EXCH04.marvell.com>
References: <1464358702-19083-1-git-send-email-javier@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Xinming Hu <huxm@marvell.com>, Kalle Valo <kvalo@codeaurora.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"Nishant Sarmukadam" <nishants@marvell.com>
To: Javier Martinez Canillas <javier@osg.samsung.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464358702-19083-1-git-send-email-javier@osg.samsung.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Javier Martinez Canillas [mailto:javier@osg.samsung.com]
> Sent: Friday, May 27, 2016 7:48 PM
> To: linux-kernel@vger.kernel.org
> Cc: Xinming Hu; Javier Martinez Canillas; Amitkumar Karwar; Kalle Valo;
> netdev@vger.kernel.org; linux-wireless@vger.kernel.org; Nishant
> Sarmukadam
> Subject: [PATCH 0/8] mwifiex: Fix some error handling issues in
> mwifiex_sdio_probe() function
> 
> Hello,
> 
> While booting a system with a mwifiex WiFi card, I noticed the following
> missleading error message:
> 
> [  12.480042] mwifiex_sdio mmc2:0001:1: sdio platform data not available
> 
> This error only applies to platforms that define a child node for the
> SDIO device, but it's currently shown even in platforms that don't have
> a child node defined.
> 
> So this series fixes this issue and others I found in the .probe
> function (mostly related to error handling and the error path) while
> looking at it.
> 
> Best regards,
> Javier
> 
> 
> Javier Martinez Canillas (8):
>   mwifiex: only call mwifiex_sdio_probe_of() if dev has an OF node
>   mwifiex: propagate sdio_enable_func() errno code in
>     mwifiex_sdio_probe()
>   mwifiex: propagate mwifiex_add_card() errno code in
>     mwifiex_sdio_probe()
>   mwifiex: consolidate mwifiex_sdio_probe() error paths
>   mwifiex: use dev_err() instead of pr_err() in mwifiex_sdio_probe()
>   mwifiex: check if mwifiex_sdio_probe_of() fails and return error
>   mwifiex: don't print an error if an optional DT property is missing
>   mwifiex: use better message and error code when OF node doesn't match
> 
>  drivers/net/wireless/marvell/mwifiex/sdio.c | 46 ++++++++++++++++++----
> -------
>  1 file changed, 28 insertions(+), 18 deletions(-)
> 

Thanks for fixing the error handling code. These patches look fine to me.

Acked-by: Amitkumar Karwar <akarwar@marvell.com>

Regards,
Amitkumar
