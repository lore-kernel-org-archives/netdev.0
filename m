From: Amitkumar Karwar <akarwar-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
Subject: RE: [PATCH 1/1] mwifiex: remove superfluous condition
Date: Mon, 1 Aug 2016 10:46:12 +0000
Message-ID: <b7cf72a967fe4f58a59a8ba2ce43c299@SC-EXCH04.marvell.com>
References: <1469961555-2123-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Heinrich Schuchardt <xypron.glpk-Mmb7MZpHnFY@public.gmane.org>,
	Nishant Sarmukadam <nishants-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1469961555-2123-1-git-send-email-xypron.glpk-Mmb7MZpHnFY@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> From: Heinrich Schuchardt [mailto:xypron.glpk-Mmb7MZpHnFY@public.gmane.org]
> Sent: Sunday, July 31, 2016 4:09 PM
> To: Amitkumar Karwar; Nishant Sarmukadam; Kalle Valo
> Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-
> kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Heinrich Schuchardt
> Subject: [PATCH 1/1] mwifiex: remove superfluous condition
> 
> for_each_property_of_node is only executed if the property prop is not
> NULL.
> 
> Signed-off-by: Heinrich Schuchardt <xypron.glpk-Mmb7MZpHnFY@public.gmane.org>
> ---
>  drivers/net/wireless/marvell/mwifiex/sta_cmd.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/wireless/marvell/mwifiex/sta_cmd.c
> b/drivers/net/wireless/marvell/mwifiex/sta_cmd.c
> index 7897037..128add8 100644
> --- a/drivers/net/wireless/marvell/mwifiex/sta_cmd.c
> +++ b/drivers/net/wireless/marvell/mwifiex/sta_cmd.c
> @@ -1482,7 +1482,7 @@ int mwifiex_dnld_dt_cfgdata(struct mwifiex_private
> *priv,
>  			continue;
> 
>  		/* property header is 6 bytes, data must fit in cmd buffer
> */
> -		if (prop && prop->value && prop->length > 6 &&
> +		if (prop->value && prop->length > 6 &&
>  		    prop->length <= MWIFIEX_SIZE_OF_CMD_BUFFER - S_DS_GEN) {
>  			ret = mwifiex_send_cmd(priv, HostCmd_CMD_CFG_DATA,
>  					       HostCmd_ACT_GEN_SET, 0,

Thanks. The patch looks fine to me.

Acked-by: Amitkumar Karwar <akarwar-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>

Regards,
Amitkumar
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
