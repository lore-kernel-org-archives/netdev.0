From: Helmut Schaa <helmut.schaa@googlemail.com>
Subject: Re: [PATCH 2/3] net: wireless: rt2x00: Pointer issue
Date: Thu, 21 Jan 2016 17:59:07 +0100
Message-ID: <CAGXE3d8buJC8kSvDJV8u_2OeWKbJOVrNkdFM5qxwuS_7DqH=JA@mail.gmail.com>
References: <1445116005-28670-1-git-send-email-paulmcquad@gmail.com>
	<1445116005-28670-2-git-send-email-paulmcquad@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stanislaw Gruszka <sgruszka@redhat.com>, kvalo@codeaurora.org,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Paul McQuade <paulmcquad@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445116005-28670-2-git-send-email-paulmcquad@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 17, 2015 at 11:06 PM, Paul McQuade <paulmcquad@gmail.com> wrote:
> Code Style: pointer is declared wrong
>
> Signed-off-by: Paul McQuade <paulmcquad@gmail.com>

Thanks for fixing this code style issue.

Acked-by: Helmut Schaa <helmut.schaa@googlemail.com>

> ---
>  drivers/net/wireless/rt2x00/rt2x00.h | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/wireless/rt2x00/rt2x00.h b/drivers/net/wireless/rt2x00/rt2x00.h
> index 6f8310a..b052e87 100644
> --- a/drivers/net/wireless/rt2x00/rt2x00.h
> +++ b/drivers/net/wireless/rt2x00/rt2x00.h
> @@ -380,7 +380,7 @@ struct rt2x00_intf {
>         atomic_t seqno;
>  };
>
> -static inline struct rt2x00_intf* vif_to_intf(struct ieee80211_vif *vif)
> +static inline struct rt2x00_intf *vif_to_intf(struct ieee80211_vif *vif)
>  {
>         return (struct rt2x00_intf *)vif->drv_priv;
>  }
> @@ -507,7 +507,7 @@ struct rt2x00_sta {
>         int wcid;
>  };
>
> -static inline struct rt2x00_sta* sta_to_rt2x00_sta(struct ieee80211_sta *sta)
> +static inline struct rt2x00_sta *sta_to_rt2x00_sta(struct ieee80211_sta *sta)
>  {
>         return (struct rt2x00_sta *)sta->drv_priv;
>  }
> --
> 2.6.1
>
