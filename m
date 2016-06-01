From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH 7/8] mwifiex: don't print an error if an optional DT
 property is missing
Date: Wed, 1 Jun 2016 14:20:55 +1000
Message-ID: <CAGRGNgUZ+mG_KzhiOzquB3qd-V_Pdbazag=nrFpG87mRQGmXLg@mail.gmail.com>
References: <1464358702-19083-1-git-send-email-javier@osg.samsung.com> <1464358702-19083-8-git-send-email-javier@osg.samsung.com>
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
In-Reply-To: <1464358702-19083-8-git-send-email-javier@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

On Sat, May 28, 2016 at 12:18 AM, Javier Martinez Canillas
<javier@osg.samsung.com> wrote:
> The Documentation/devicetree/bindings/net/wireless/marvell-sd8xxx.txt DT
> binding document say that the "interrupts" property in the child node is
> optional. So the property being missed shouldn't be treated as an error.

Have you checked whether it is truly optional? I.e. nothing else
breaks if this property isn't set?

> Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>

Other than that, this looks sensible to me.

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
