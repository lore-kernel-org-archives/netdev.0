From: Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2 10/10] nl80211: Prefer kcalloc over kzalloc
Date: Mon, 30 May 2016 15:32:14 +1000
Message-ID: <CAGRGNgXVvX2zjp7HjNsYJP=tSc3XM7O5sSXf9=8JmPdd20QJtw@mail.gmail.com>
References: <cover.1464576022.git.kirtika.ruchandani@gmail.com> <ca13e9bde679512a872e5136c177676d0238dc25.1464576022.git.kirtika.ruchandani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Tina Ruchandani <ruchandani.tina-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Kirtika Ruchandani <kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <ca13e9bde679512a872e5136c177676d0238dc25.1464576022.git.kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi All,

On Mon, May 30, 2016 at 12:54 PM, Kirtika Ruchandani
<kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> This patch fixes the checkpatch.pl warning -
> "prefer kcalloc over kzalloc with multiply"
>
> Signed-off-by: Kirtika Ruchandani <kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Looks right to me.

Reviewed-by: Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Thanks,

Julian Calaby


> ---
>  net/wireless/nl80211.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
> index 46757af..2964406 100644
> --- a/net/wireless/nl80211.c
> +++ b/net/wireless/nl80211.c
> @@ -9482,7 +9482,7 @@ static int nl80211_parse_wowlan_nd(struct cfg80211_registered_device *rdev,
>         struct nlattr **tb;
>         int err;
>
> -       tb = kzalloc(NUM_NL80211_ATTR * sizeof(*tb), GFP_KERNEL);
> +       tb = kcalloc(NUM_NL80211_ATTR, sizeof(*tb), GFP_KERNEL);
>         if (!tb)
>                 return -ENOMEM;
>
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
