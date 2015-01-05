From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 2/2] Fix copy-paste bug: assign from src struct not dest
Date: Mon, 05 Jan 2015 10:54:31 +0100
Message-ID: <1420451671.9459.1.camel@sipsolutions.net>
References: <1420394427-19509-1-git-send-email-me@mortis.eu>
	 <1420394427-19509-2-git-send-email-me@mortis.eu>
	 (sfid-20150104_201205_499836_1F2052B2)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Kalle Valo <kvalo@codeaurora.org>,
	Eliad Peller <eliad@wizery.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Arik Nemtsov <arik@wizery.com>,
	"open list:TI WILINK WIRELES..." <linux-wireless@vger.kernel.org>,
	"open list:NETWORKING DRIVERS" <netdev@vger.kernel.org>
To: Giel van Schijndel <me@mortis.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420394427-19509-2-git-send-email-me@mortis.eu> (sfid-20150104_201205_499836_1F2052B2)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2015-01-04 at 19:00 +0100, Giel van Schijndel wrote:
> ---
>  drivers/net/wireless/ti/wlcore/acx.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/wireless/ti/wlcore/acx.c b/drivers/net/wireless/ti/wlcore/acx.c
> index beb354c..93a2fa8 100644
> --- a/drivers/net/wireless/ti/wlcore/acx.c
> +++ b/drivers/net/wireless/ti/wlcore/acx.c
> @@ -1725,7 +1725,7 @@ int wl12xx_acx_config_hangover(struct wl1271 *wl)
>  	acx->decrease_delta             = conf->decrease_delta;
>  	acx->quiet_time                 = conf->quiet_time;
>  	acx->increase_time              = conf->increase_time;
> -	acx->window_size                = acx->window_size;
> +	acx->window_size                = conf->window_size;

It would be far better to fix the bug *first*, that way the bugfix can
be cherry-picked/applied to trees that don't have the alignment.

(And anyway I question the value of the alignment - if you really want
to make this bug disappear you could perhaps use a macro)

johannes
