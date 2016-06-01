From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH 4/8] mwifiex: consolidate mwifiex_sdio_probe() error paths
Date: Wed, 1 Jun 2016 14:18:40 +1000
Message-ID: <CAGRGNgUwtffHta-ZWpG_UeuTcp62GXAKpNJNYOLetRi7XvS-7g@mail.gmail.com>
References: <1464358702-19083-1-git-send-email-javier@osg.samsung.com> <1464358702-19083-5-git-send-email-javier@osg.samsung.com>
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
In-Reply-To: <1464358702-19083-5-git-send-email-javier@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

On Sat, May 28, 2016 at 12:18 AM, Javier Martinez Canillas
<javier@osg.samsung.com> wrote:
> Instead of duplicating part of the cleanups needed in case of an error
> in .probe callback, have a single error path and use goto labels as is
> common practice in the kernel.
>
> This also has the nice side effect that the cleanup operations are made
> in the inverse order of their counterparts, which was not the case for
> the mwifiex_add_card() error path.
>
> Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>

This looks sensible to me.

Reviewed-by: Julian Calaby <julian.calaby@gmail.com>

> ---
>
>  drivers/net/wireless/marvell/mwifiex/sdio.c | 17 +++++++++++------
>  1 file changed, 11 insertions(+), 6 deletions(-)

Thanks,

-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
