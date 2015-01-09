From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH RESEND 2/2] wlcore: align member-assigns in a structure-copy block
Date: Fri, 09 Jan 2015 19:03:45 +0200
Message-ID: <87vbkfga32.fsf@kamboji.qca.qualcomm.com>
References: <1420394427-19509-1-git-send-email-me@mortis.eu>
	<1420659525-22975-1-git-send-email-me@mortis.eu>
	<1420659525-22975-2-git-send-email-me@mortis.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eliad Peller <eliad-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Arik Nemtsov <arik-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list:TI WILINK WIRELES...),
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list:NETWORKING DRIVERS)
To: Giel van Schijndel <me-sZ9Uef1cvPWHXe+LvDLADg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1420659525-22975-2-git-send-email-me-sZ9Uef1cvPWHXe+LvDLADg@public.gmane.org> (Giel van
	Schijndel's message of "Wed, 7 Jan 2015 20:38:38 +0100")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Giel van Schijndel <me-sZ9Uef1cvPWHXe+LvDLADg@public.gmane.org> writes:

> This highlights the differences (e.g. the bug fixed in the previous
> commit).
>
> Signed-off-by: Giel van Schijndel <me-sZ9Uef1cvPWHXe+LvDLADg@public.gmane.org>
> ---
>  drivers/net/wireless/ti/wlcore/acx.c | 22 +++++++++++-----------
>  1 file changed, 11 insertions(+), 11 deletions(-)
>
> diff --git a/drivers/net/wireless/ti/wlcore/acx.c b/drivers/net/wireless/ti/wlcore/acx.c
> index f28fa3b..93a2fa8 100644
> --- a/drivers/net/wireless/ti/wlcore/acx.c
> +++ b/drivers/net/wireless/ti/wlcore/acx.c
> @@ -1715,17 +1715,17 @@ int wl12xx_acx_config_hangover(struct wl1271 *wl)
>  		goto out;
>  	}
>  
> -	acx->recover_time = cpu_to_le32(conf->recover_time);
> -	acx->hangover_period = conf->hangover_period;
> -	acx->dynamic_mode = conf->dynamic_mode;
> -	acx->early_termination_mode = conf->early_termination_mode;
> -	acx->max_period = conf->max_period;
> -	acx->min_period = conf->min_period;
> -	acx->increase_delta = conf->increase_delta;
> -	acx->decrease_delta = conf->decrease_delta;
> -	acx->quiet_time = conf->quiet_time;
> -	acx->increase_time = conf->increase_time;
> -	acx->window_size = conf->window_size;
> +	acx->recover_time               = cpu_to_le32(conf->recover_time);
> +	acx->hangover_period            = conf->hangover_period;
> +	acx->dynamic_mode               = conf->dynamic_mode;
> +	acx->early_termination_mode     = conf->early_termination_mode;
> +	acx->max_period                 = conf->max_period;
> +	acx->min_period                 = conf->min_period;
> +	acx->increase_delta             = conf->increase_delta;
> +	acx->decrease_delta             = conf->decrease_delta;
> +	acx->quiet_time                 = conf->quiet_time;
> +	acx->increase_time              = conf->increase_time;
> +	acx->window_size                = conf->window_size;

I would like to get an ACK from one of the wlcore developers if I should
apply this (or not).

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
