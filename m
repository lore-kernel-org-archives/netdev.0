From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH v3 06/18] wcn36xx: Add helper macros to cast sta to priv
Date: Tue, 19 Apr 2016 01:44:35 -0700
Message-ID: <1461055475.1917.17.camel@perches.com>
References: <1461042056-10607-1-git-send-email-bjorn.andersson@linaro.org>
	 <1461042056-10607-7-git-send-email-bjorn.andersson@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pontus Fuchs <pontus.fuchs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Eugene Krasnikov <k.eugene.e-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1461042056-10607-7-git-send-email-bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-04-18 at 22:00 -0700, Bjorn Andersson wrote:
> From: Pontus Fuchs <pontus.fuchs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>=20
> While poking at this I also change two related things. I rename one
> variable to make the names consistent. I also move one assignment of
> priv_sta to the declaration to save a few lines.

trivia:

The commit subject is a bit misleading as this adds
the preferred static
inline not a macro.

> diff --git a/drivers/net/wireless/ath/wcn36xx/wcn36xx.h b/drivers/net=
/wireless/ath/wcn36xx/wcn36xx.h
[]
> @@ -275,4 +275,10 @@ struct ieee80211_vif *wcn36xx_priv_to_vif(struct=
 wcn36xx_vif *vif_priv)
> =A0	return container_of((void *) vif_priv, struct ieee80211_vif, drv_=
priv);
> =A0}
> =A0
> +static inline
> +struct wcn36xx_sta *wcn36xx_sta_to_priv(struct ieee80211_sta *sta)
> +{
> +	return (struct wcn36xx_sta *)sta->drv_priv;
> +}
> +
> =A0#endif	/* _WCN36XX_H_ */

And this could be const struct ieee8021_sta *sta
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
