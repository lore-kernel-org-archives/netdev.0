From: Andy Shevchenko <andy.shevchenko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/2] Align member-assigns in a structure-copy block
Date: Wed, 7 Jan 2015 20:40:57 +0200
Message-ID: <CAHp75Vetc+fgv=YrqPuW9YChez82h7N7VeX_5bW5tpXm2j=h7g@mail.gmail.com>
References: <1420394427-19509-1-git-send-email-me@mortis.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Eliad Peller <eliad-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Arik Nemtsov <arik-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>,
	"open list:TI WILINK WIRELES..." <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"open list:NETWORKING DRIVERS" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Giel van Schijndel <me-sZ9Uef1cvPWHXe+LvDLADg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1420394427-19509-1-git-send-email-me-sZ9Uef1cvPWHXe+LvDLADg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 4, 2015 at 8:00 PM, Giel van Schijndel <me-sZ9Uef1cvPWHXe+LvDLADg@public.gmane.org> wrote:
> This highlights the differences (errors).

Seems like patch for the patch. Just fix an error like it's done here:
http://www.spinics.net/lists/linux-wireless/msg131667.html


> ---
>  drivers/net/wireless/ti/wlcore/acx.c | 22 +++++++++++-----------
>  1 file changed, 11 insertions(+), 11 deletions(-)
>
> diff --git a/drivers/net/wireless/ti/wlcore/acx.c b/drivers/net/wireless/ti/wlcore/acx.c
> index b924cea..beb354c 100644
> --- a/drivers/net/wireless/ti/wlcore/acx.c
> +++ b/drivers/net/wireless/ti/wlcore/acx.c
> @@ -1715,17 +1715,17 @@ int wl12xx_acx_config_hangover(struct wl1271 *wl)
>                 goto out;
>         }
>
> -       acx->recover_time = cpu_to_le32(conf->recover_time);
> -       acx->hangover_period = conf->hangover_period;
> -       acx->dynamic_mode = conf->dynamic_mode;
> -       acx->early_termination_mode = conf->early_termination_mode;
> -       acx->max_period = conf->max_period;
> -       acx->min_period = conf->min_period;
> -       acx->increase_delta = conf->increase_delta;
> -       acx->decrease_delta = conf->decrease_delta;
> -       acx->quiet_time = conf->quiet_time;
> -       acx->increase_time = conf->increase_time;
> -       acx->window_size = acx->window_size;
> +       acx->recover_time               = cpu_to_le32(conf->recover_time);
> +       acx->hangover_period            = conf->hangover_period;
> +       acx->dynamic_mode               = conf->dynamic_mode;
> +       acx->early_termination_mode     = conf->early_termination_mode;
> +       acx->max_period                 = conf->max_period;
> +       acx->min_period                 = conf->min_period;
> +       acx->increase_delta             = conf->increase_delta;
> +       acx->decrease_delta             = conf->decrease_delta;
> +       acx->quiet_time                 = conf->quiet_time;
> +       acx->increase_time              = conf->increase_time;
> +       acx->window_size                = acx->window_size;
>
>         ret = wl1271_cmd_configure(wl, ACX_CONFIG_HANGOVER, acx,
>                                    sizeof(*acx));
> --
> 2.1.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/



-- 
With Best Regards,
Andy Shevchenko
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
