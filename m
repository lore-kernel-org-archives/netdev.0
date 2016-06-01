From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH 6/8] mwifiex: check if mwifiex_sdio_probe_of() fails and
 return error
Date: Wed, 1 Jun 2016 14:19:28 +1000
Message-ID: <CAGRGNgVUogVNRVfPaGpDBRo2e-ke5U6nQB8KhMHOc+cRbiGnHg@mail.gmail.com>
References: <1464358702-19083-1-git-send-email-javier@osg.samsung.com> <1464358702-19083-7-git-send-email-javier@osg.samsung.com>
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
In-Reply-To: <1464358702-19083-7-git-send-email-javier@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

On Sat, May 28, 2016 at 12:18 AM, Javier Martinez Canillas
<javier@osg.samsung.com> wrote:
> The function can fail so the returned value should be checked
> and the error propagated to the caller in case of a failure.
>
> Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>

This looks sensible to me.

Reviewed-by: Julian Calaby <julian.calaby@gmail.com>

> ---
>
>  drivers/net/wireless/marvell/mwifiex/sdio.c | 9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)

Thanks,

-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
