From: Enric Balletbo Serra <eballetbo@gmail.com>
Subject: Re: [PATCH 0/8] mwifiex: Fix some error handling issues in
 mwifiex_sdio_probe() function
Date: Mon, 30 May 2016 11:57:08 +0200
Message-ID: <CAFqH_517amqPDVCpK3b=RFLumV1K1yU02f_bLp50iudCjnvoDw@mail.gmail.com>
References: <1464358702-19083-1-git-send-email-javier@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org, Xinming Hu <huxm@marvell.com>,
	Amitkumar Karwar <akarwar@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>, netdev@vger.kernel.org,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Nishant Sarmukadam <nishants@marvell.com>
To: Javier Martinez Canillas <javier@osg.samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464358702-19083-1-git-send-email-javier@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Javier,

2016-05-27 16:18 GMT+02:00 Javier Martinez Canillas <javier@osg.samsung.com>:
> Hello,
>
> While booting a system with a mwifiex WiFi card, I noticed the following
> missleading error message:
>
> [  12.480042] mwifiex_sdio mmc2:0001:1: sdio platform data not available
>
> This error only applies to platforms that define a child node for the SDIO
> device, but it's currently shown even in platforms that don't have a child
> node defined.
>
> So this series fixes this issue and others I found in the .probe function
> (mostly related to error handling and the error path) while looking at it.
>

The patches looks good to me and tested on my Veyron Chromebook, so
for all this series:

Tested-by: Enric Balletbo i Serra <enric.balletbo@collabora.com>

Thanks,
  Enric

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
>  drivers/net/wireless/marvell/mwifiex/sdio.c | 46 ++++++++++++++++++-----------
>  1 file changed, 28 insertions(+), 18 deletions(-)
>
> --
> 2.5.5
>
