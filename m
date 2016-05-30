From: Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2 07/10] nl80211: Avoid multiple assignments on same line
Date: Mon, 30 May 2016 15:30:59 +1000
Message-ID: <CAGRGNgX0B-Px5r4-Ad7f4B3Q6UrY=aGLn9g4Xd+=kJoXWt-_dQ@mail.gmail.com>
References: <cover.1464576022.git.kirtika.ruchandani@gmail.com> <637c25b980379d1a98d7c57cc247d49ef295cbc5.1464576022.git.kirtika.ruchandani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Tina Ruchandani <ruchandani.tina-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Kirtika Ruchandani <kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <637c25b980379d1a98d7c57cc247d49ef295cbc5.1464576022.git.kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi All,

On Mon, May 30, 2016 at 12:53 PM, Kirtika Ruchandani
<kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> This patch fixes the checkpatch.pl warning "multiple assignments
> should be avoided."
>
> Signed-off-by: Kirtika Ruchandani <kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

I'm not sure I agree with checkpatch here, but this looks right to me.

Reviewed-by: Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Thanks,

Julian Calaby


> ---
>  net/wireless/nl80211.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
> index ad7cdce..6f8e2a7 100644
> --- a/net/wireless/nl80211.c
> +++ b/net/wireless/nl80211.c
> @@ -2603,7 +2603,8 @@ static int nl80211_set_interface(struct sk_buff *skb, struct genl_info *info)
>
>         memset(&params, 0, sizeof(params));
>
> -       otype = ntype = dev->ieee80211_ptr->iftype;
> +       otype = dev->ieee80211_ptr->iftype;
> +       ntype = dev->ieee80211_ptr->iftype;
>
>         if (info->attrs[NL80211_ATTR_IFTYPE]) {
>                 ntype = nla_get_u32(info->attrs[NL80211_ATTR_IFTYPE]);
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
