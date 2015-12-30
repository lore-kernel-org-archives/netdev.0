From: Souptick Joarder <jrdr.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] mac80211: Make addr const in SET_IEEE80211_PERM_ADDR()
Date: Wed, 30 Dec 2015 22:17:04 +0530
Message-ID: <CAFqt6zam7maK4wFrKo=yqWxaBkVDJhZGbKAFAdmcZPQonXTcxA@mail.gmail.com>
References: <1450946006-7498-1-git-send-email-bjorn.andersson@sonymobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bjorn Andersson <bjorn-UYDU3/A3LUY@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1450946006-7498-1-git-send-email-bjorn.andersson-/MT0OVThwyLZJqsBc5GL+g@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

HI Bjorn,

On Thu, Dec 24, 2015 at 2:03 PM, Bjorn Andersson <bjorn-UYDU3/A3LUY@public.gmane.org> wrote:
> Make the addr parameter const in SET_IEEE80211_PERM_ADDR() to save
> clients from having to cast away a const qualifier.
>
> Signed-off-by: Bjorn Andersson <bjorn.andersson-/MT0OVThwyLZJqsBc5GL+g@public.gmane.org>
> ---
>  include/net/mac80211.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/include/net/mac80211.h b/include/net/mac80211.h
> index 7c30faff245f..a6f3c9c4b7c2 100644
> --- a/include/net/mac80211.h
> +++ b/include/net/mac80211.h
> @@ -2167,7 +2167,7 @@ static inline void SET_IEEE80211_DEV(struct ieee80211_hw *hw, struct device *dev
>   * @hw: the &struct ieee80211_hw to set the MAC address for
>   * @addr: the address to set
>   */
> -static inline void SET_IEEE80211_PERM_ADDR(struct ieee80211_hw *hw, u8 *addr)
> +static inline void SET_IEEE80211_PERM_ADDR(struct ieee80211_hw *hw, const u8 *addr)

I guess without const or with const doesn't make much difference here.
Correct me if I am wrong.
>  {
>         memcpy(hw->wiphy->perm_addr, addr, ETH_ALEN);
>  }
> --
> 2.5.0
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-Souptick
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
