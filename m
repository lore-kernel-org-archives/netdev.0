From: Masanari Iida <standby24x7-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] cfg80211/mac80211: Fix warning on make xmldocs caused by cfg80211.h
Date: Thu, 8 May 2014 00:49:17 +0900
Message-ID: <CALLJCT2Y=0v7m0hSSBTaAQMqeNCfyXQS=S8pEERYev9YuyUqhw@mail.gmail.com>
References: <1399041597-27409-1-git-send-email-standby24x7@gmail.com>
	<1399041597-27409-2-git-send-email-standby24x7@gmail.com>
	<1399097729.5873.2.camel@dubbel>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Luciano Coelho <luciano.coelho-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1399097729.5873.2.camel@dubbel>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,
Your patch fixed the symptom.
I have tested it on linux-next as of 7th/May.
Thank you.

Tested-by: Masanari Iida <standby24x7-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Regards,
Masanari

On Sat, May 3, 2014 at 3:15 PM, Luciano Coelho <luciano.coelho-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> wrote:
> Hi,
>
> A better way to fix this would be to add "iftype" to the function
> prototype, since we don't usually use nameless arguments:
>
> diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
> index 43c674e..f9e7373 100644
> --- a/include/net/cfg80211.h
> +++ b/include/net/cfg80211.h
> @@ -458,7 +458,7 @@ bool cfg80211_chandef_usable(struct wiphy *wiphy,
>   */
>  int cfg80211_chandef_dfs_required(struct wiphy *wiphy,
>                                   const struct cfg80211_chan_def *chandef,
> -                                 enum nl80211_iftype);
> +                                 enum nl80211_iftype iftype);
>
>  /**
>   * ieee80211_chandef_rate_flags - returns rate flags for a channel
>
> --
> Cheers,
> Luca.
>
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
