From: Mohammed Shafi <shafi.wireless-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] Build fix in drivers/net/wireless/ath/ath9k/main.c
Date: Thu, 28 Jun 2012 10:39:41 +0530
Message-ID: <CAD2nsn3Kt49mkkE99+8u5AzN+pSw8ktr7ABx3-B74qvQ9VSpWg@mail.gmail.com>
References: <1340824779-5157-1-git-send-email-asido4@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mcgrof-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org, jouni-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org,
	vthiagar-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org, senthilb-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Arvydas Sidorenko <asido4-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1340824779-5157-1-git-send-email-asido4-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

On Thu, Jun 28, 2012 at 12:49 AM, Arvydas Sidorenko <asido4-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> =
wrote:
> Commit fad29cd2f59949581050a937786c2c9bc78b2f04 broke the build if
> no CONFIG_ATH9K_BTCOEX_SUPPORT is enabled.
>
> Signed-off-by: Arvydas Sidorenko <asido4-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
> =A0drivers/net/wireless/ath/ath9k/main.c | =A0 =A02 ++
> =A01 files changed, 2 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wire=
less/ath/ath9k/main.c
> index c14cf5a..e4e73f0 100644
> --- a/drivers/net/wireless/ath/ath9k/main.c
> +++ b/drivers/net/wireless/ath/ath9k/main.c
> @@ -151,8 +151,10 @@ static void __ath_cancel_work(struct ath_softc *=
sc)
> =A0 =A0 =A0 =A0cancel_delayed_work_sync(&sc->tx_complete_work);
> =A0 =A0 =A0 =A0cancel_delayed_work_sync(&sc->hw_pll_work);
>
> +#ifdef CONFIG_ATH9K_BTCOEX_SUPPORT
> =A0 =A0 =A0 =A0if (ath9k_hw_mci_is_enabled(sc->sc_ah))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cancel_work_sync(&sc->mci_work);
> +#endif
> =A0}
>
> =A0static void ath_cancel_work(struct ath_softc *sc)
> --
> 1.7.8.6

thanks for the patch, but it was just sent some time back
http://www.spinics.net/lists/linux-wireless/msg93078.html


>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wirel=
ess" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html



--=20
thanks,
shafi
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
