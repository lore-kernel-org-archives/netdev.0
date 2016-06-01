From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH 3/8] mwifiex: propagate mwifiex_add_card() errno code in mwifiex_sdio_probe()
Date: Wed, 1 Jun 2016 14:17:19 +1000
Message-ID: <CAGRGNgXYBucEh+D3ceHR5xg4fPuNhx-CCjHPRewhNWZJzgV-kg@mail.gmail.com>
References: <1464358702-19083-1-git-send-email-javier@osg.samsung.com> <1464358702-19083-4-git-send-email-javier@osg.samsung.com>
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
In-Reply-To: <1464358702-19083-4-git-send-email-javier@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

On Sat, May 28, 2016 at 12:18 AM, Javier Martinez Canillas
<javier@osg.samsung.com> wrote:
> There's only a check if mwifiex_add_card() returned a nonzero value, but
> the actual error code is neither stored nor propagated to the caller. So
> instead of always returning -1 (which is -EPERM and not a suitable errno
> code in this case), propagate the value returned by mwifiex_add_card().
>
> Patch also removes the assignment of sdio_disable_func() returned value
> since it was overwritten anyways and what matters is to know the error
> value returned by the first function that failed.
>
> Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>

This looks sensible to me.

Reviewed-by: Julian Calaby <julian.calaby@gmail.com>

> ---
>
>  drivers/net/wireless/marvell/mwifiex/sdio.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)

Thanks,

-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
