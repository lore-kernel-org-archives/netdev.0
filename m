From: Jouni Malinen <j@w1.fi>
Subject: Re: [PATCH] mac80211_hwsim: Added vendor echo command
Date: Fri, 24 Jun 2016 23:47:59 +0300
Message-ID: <20160624204759.GA15514@w1.fi>
References: <1466756034-5485-1-git-send-email-erik.stromdahl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Erik Stromdahl <erik.stromdahl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1466756034-5485-1-git-send-email-erik.stromdahl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 24, 2016 at 10:13:54AM +0200, Erik Stromdahl wrote:
> The purpose of the echo command is to provide a test
> facility for user space programs.

> diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
> @@ -332,14 +332,16 @@ static const struct ieee80211_rate hwsim_rates[] = {
>  #define QCA_NL80211_SUBCMD_TEST 1
> +#define QCA_NL80211_SUBCMD_ECHO 2

NAK. That QCA vendor specific value has not been assigned nor have I
even seen a request to assign such a value.

>  enum qca_nl80211_vendor_subcmds {
>  	QCA_WLAN_VENDOR_ATTR_TEST = 8,
> -	QCA_WLAN_VENDOR_ATTR_MAX = QCA_WLAN_VENDOR_ATTR_TEST
> +	QCA_WLAN_VENDOR_ATTR_ECHO,

And this vendor attribute value has already been assigned for another
purpose.

It is no acceptable to pick arbitrary values of identifiers without
proper request to the owner of the OUI that is used to assign the
values.

As far as the QCA vendor specific identifiers are concerned, their
assignment process is described here:
http://w1.fi/cgit/hostap/plain/src/common/qca-vendor.h

Please do not submit kernel changes that use any unassigned vendor
identifier or even worse, a value that have already been assigned for a
completely different purpose.
 
-- 
Jouni Malinen                                            PGP id EFC895FA
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
