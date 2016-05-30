From: Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2 09/10] nl80211: Fix checkpatch.pl warning
Date: Mon, 30 May 2016 15:31:51 +1000
Message-ID: <CAGRGNgVRGoqCeeVWq_zsqyKdfuGdEfiTimcwv3fBZAD5n8Bnhg@mail.gmail.com>
References: <cover.1464576022.git.kirtika.ruchandani@gmail.com> <2b42b54b8128bb953569021ddadce77499859a79.1464576022.git.kirtika.ruchandani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Tina Ruchandani <ruchandani.tina-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Kirtika Ruchandani <kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2b42b54b8128bb953569021ddadce77499859a79.1464576022.git.kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi All,

On Mon, May 30, 2016 at 12:54 PM, Kirtika Ruchandani
<kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> This patch fixes the checkpatch.pl warning "foo * bar should be
> foo *bar"
>
> Signed-off-by: Kirtika Ruchandani <kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Looks right to me.

Reviewed-by: Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Thanks,

Julian Calaby


> ---
>  net/wireless/nl80211.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
> index c6d870e..46757af 100644
> --- a/net/wireless/nl80211.c
> +++ b/net/wireless/nl80211.c
> @@ -12214,7 +12214,7 @@ void nl80211_send_ibss_bssid(struct cfg80211_registered_device *rdev,
>  }
>
>  void cfg80211_notify_new_peer_candidate(struct net_device *dev, const u8 *addr,
> -                                       const u8* ie, u8 ie_len, gfp_t gfp)
> +                                       const u8 *ie, u8 ie_len, gfp_t gfp)
>  {
>         struct wireless_dev *wdev = dev->ieee80211_ptr;
>         struct cfg80211_registered_device *rdev = wiphy_to_rdev(wdev->wiphy);
> @@ -13362,7 +13362,7 @@ void cfg80211_tdls_oper_request(struct net_device *dev, const u8 *peer,
>  }
>  EXPORT_SYMBOL(cfg80211_tdls_oper_request);
>
> -static int nl80211_netlink_notify(struct notifier_block * nb,
> +static int nl80211_netlink_notify(struct notifier_block *nb,
>                                   unsigned long state,
>                                   void *_notify)
>  {
> --
> 2.8.0.rc3.226.g39d4020
>



-- 
Julian Calaby

Email: julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Profile: http://www.google.com/profiles/julian.calaby/
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
