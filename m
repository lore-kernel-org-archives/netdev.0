From: Luca Coelho <luca-XPOmlcxoEMv1KXRcyAk9cg@public.gmane.org>
Subject: Re: [PATCH 0/6 3.18] Fixes for iwlwifi drivers
Date: Thu, 30 Oct 2014 13:08:32 +0200
Message-ID: <1414667312.27833.22.camel@coelho.fi>
References: <1414642633-3700-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Murilo Opsfelder Araujo <mopsfelder-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1414642633-3700-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The cover-letter subject is wrong. :) I guess you meant
s/iwlwifi/rtlwifi/ ;)

--
Luca.

On Wed, 2014-10-29 at 23:17 -0500, Larry Finger wrote:
> Some late changes to rtlwifi made some of the older drivers not start correctly.
> These patches should be applied to 3.18.
> 
> Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
> Cc: Murilo Opsfelder Araujo <mopsfelder-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> 
> Larry Finger (6):
>   rtlwifi: rtl8192ce: rtl8192de: rtl8192se: Fix handling for missing
>     get_btc_status
>   rtlwifi: rtl8192se: Fix duplicate calls to ieee80211_register_hw()
>   rtlwifi: rtl8192se: Add missing section to read descriptor setting
>   rtlwifi: rtl8192ce: Add missing section to read descriptor setting
>   rtlwifi: rtl8821ae: Remove extra semicolons
>   rtlwifi: rtl8192se: Fix firmware loading
> 
>  drivers/net/wireless/rtlwifi/core.c          |  6 ++++++
>  drivers/net/wireless/rtlwifi/core.h          |  1 +
>  drivers/net/wireless/rtlwifi/rtl8192ce/def.h |  2 ++
>  drivers/net/wireless/rtlwifi/rtl8192ce/sw.c  |  1 +
>  drivers/net/wireless/rtlwifi/rtl8192ce/trx.c |  3 +++
>  drivers/net/wireless/rtlwifi/rtl8192de/sw.c  |  1 +
>  drivers/net/wireless/rtlwifi/rtl8192se/def.h |  2 ++
>  drivers/net/wireless/rtlwifi/rtl8192se/sw.c  | 22 +++-------------------
>  drivers/net/wireless/rtlwifi/rtl8192se/trx.c |  3 +++
>  drivers/net/wireless/rtlwifi/rtl8821ae/phy.c | 12 ++++++------
>  10 files changed, 28 insertions(+), 25 deletions(-)
> 


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
