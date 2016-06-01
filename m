From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH 2/8] mwifiex: propagate sdio_enable_func() errno code in mwifiex_sdio_probe()
Date: Wed, 1 Jun 2016 14:15:12 +1000
Message-ID: <CAGRGNgW_Re_bHnhkLW1wUGANOheoizm-zNK996nJQqBZJ=XY4w@mail.gmail.com>
References: <1464358702-19083-1-git-send-email-javier@osg.samsung.com> <1464358702-19083-3-git-send-email-javier@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Xinming Hu <huxm@marvell.com>,
	Amitkumar Karwar <akarwar@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Nishant Sarmukadam <nishants@marvell.com>
To: Javier Martinez Canillas <javier@osg.samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464358702-19083-3-git-send-email-javier@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

On Sat, May 28, 2016 at 12:18 AM, Javier Martinez Canillas
<javier@osg.samsung.com> wrote:
> If the sdio_enable_func() function fails on .probe, the -EIO errno code
> is always returned but that could make more difficult to debug and find
> the cause of why the function actually failed.
>
> Since the driver/device core prints the value returned by .probe in its
> error message propagate what was returned by sdio_enable_func() at fail.
>
> Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>

This looks sensible to me.

Reviewed-by: Julian Calaby <julian.calaby@gmail.com>

> ---
>
>  drivers/net/wireless/marvell/mwifiex/sdio.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Thanks,

-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
