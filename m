From: Mohammed Shafi <shafi.wireless@gmail.com>
Subject: Re: [PATCH] mac80211: fix build warning
Date: Mon, 25 Jun 2012 21:01:28 +0530
Message-ID: <CAD2nsn08gkYJnyYfqyZT8VX-bFPgDVZPgVSHE_QBEuXj5aEWMw@mail.gmail.com>
References: <1340637550-12669-1-git-send-email-aletes.xgr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexandre Pereira da Silva <aletes.xgr@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1340637550-12669-1-git-send-email-aletes.xgr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Mon, Jun 25, 2012 at 8:49 PM, Alexandre Pereira da Silva
<aletes.xgr@gmail.com> wrote:
> Fix:
> net/mac80211/mlme.c: In function 'ieee80211_prep_connection':
> net/mac80211/mlme.c:3035:19: warning: 'sta' may be used uninitialized=
 in
> this function
>
> Initialize sta to NULL

i think already fixed by and there in wireless-testing
http://www.spinics.net/lists/linux-wireless/msg92385.html

>
> Signed-off-by: Alexandre Pereira da Silva <aletes.xgr@gmail.com>
> ---
> =A0net/mac80211/mlme.c | =A0 =A02 +-
> =A01 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
> index 91d84cc..cfe6b43 100644
> --- a/net/mac80211/mlme.c
> +++ b/net/mac80211/mlme.c
> @@ -3032,7 +3032,7 @@ static int ieee80211_prep_connection(struct iee=
e80211_sub_if_data *sdata,
> =A0 =A0 =A0 =A0struct ieee80211_local *local =3D sdata->local;
> =A0 =A0 =A0 =A0struct ieee80211_if_managed *ifmgd =3D &sdata->u.mgd;
> =A0 =A0 =A0 =A0struct ieee80211_bss *bss =3D (void *)cbss->priv;
> - =A0 =A0 =A0 struct sta_info *sta;
> + =A0 =A0 =A0 struct sta_info *sta =3D NULL;
> =A0 =A0 =A0 =A0bool have_sta =3D false;
> =A0 =A0 =A0 =A0int err;
> =A0 =A0 =A0 =A0int ht_cfreq;
> --
> 1.7.10
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wirel=
ess" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html



--=20
thanks,
shafi
