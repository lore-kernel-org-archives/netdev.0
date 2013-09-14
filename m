From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 2/7] rtlwifi: rtl8192de: Fix smatch warnings in rtl8192de/hw.c
Date: Sat, 14 Sep 2013 23:59:54 +0400
Message-ID: <5234C03A.2070701@cogentembedded.com>
References: <1379094304-22041-1-git-send-email-Larry.Finger@lwfinger.net> <1379094304-22041-3-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1379094304-22041-3-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 09/13/2013 09:44 PM, Larry Finger wrote:

> Smatch lists the following:
>    CHECK   drivers/net/wireless/rtlwifi/rtl8192de/hw.c
> drivers/net/wireless/rtlwifi/rtl8192de/hw.c:1200 rtl92de_set_qos() info: ignoring unreachable code.
> drivers/net/wireless/rtlwifi/rtl8192de/hw.c:1200 rtl92de_set_qos() info: ignoring unreachable code.

> Dead code is removed.

    It is instead commented out, including non-dead code it seems...

> Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
> ---
>   drivers/net/wireless/rtlwifi/rtl8192de/hw.c | 2 ++
>   1 file changed, 2 insertions(+)
>
> diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/hw.c b/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
> index 7dd8f6d..c9b0894 100644
> --- a/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
> +++ b/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
> @@ -1194,6 +1194,7 @@ void rtl92d_linked_set_reg(struct ieee80211_hw *hw)
>    * mac80211 will send pkt when scan */
>   void rtl92de_set_qos(struct ieee80211_hw *hw, int aci)
>   {
> +/*
>   	struct rtl_priv *rtlpriv = rtl_priv(hw);
>   	rtl92d_dm_init_edca_turbo(hw);
>   	return;

    Shouldn't the comment start here (and *return* removed)? It's also
better to remove the dead code than just to comment it out.

> @@ -1213,6 +1214,7 @@ void rtl92de_set_qos(struct ieee80211_hw *hw, int aci)
>   		RT_ASSERT(false, "invalid aci: %d !\n", aci);
>   		break;
>   	}
> + */
>   }

WBR, Sergei


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
