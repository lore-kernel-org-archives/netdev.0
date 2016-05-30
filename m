From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH v2 05/10] nl80211: Fix checkpatch.pl NULL comparison warning
Date: Mon, 30 May 2016 15:22:25 +1000
Message-ID: <CAGRGNgVq-QcoofQtnOG19Xh=yK61N1oVuq2XSNyjJA65kL1wtQ@mail.gmail.com>
References: <cover.1464576022.git.kirtika.ruchandani@gmail.com> <cc580aa7b55b9546c71185b6b4e07aba00367e72.1464576022.git.kirtika.ruchandani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Johannes Berg <johannes@sipsolutions.net>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Tina Ruchandani <ruchandani.tina@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:34951 "EHLO
	mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752073AbcE3FWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2016 01:22:46 -0400
In-Reply-To: <cc580aa7b55b9546c71185b6b4e07aba00367e72.1464576022.git.kirtika.ruchandani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

On Mon, May 30, 2016 at 12:52 PM, Kirtika Ruchandani
<kirtika.ruchandani@gmail.com> wrote:
> This patch fixes the warning - "comparison to NULL (foo == NULL)
> could be written as (!foo)"
>
> Signed-off-by: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>

Looks right to me.

Reviewed-by: Julian Calaby <julian.calaby@gmail.com>

Thanks,

Julian Calaby

> ---
>  net/wireless/nl80211.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
> index 945405d..11cbf0b 100644
> --- a/net/wireless/nl80211.c
> +++ b/net/wireless/nl80211.c
> @@ -928,7 +928,7 @@ static struct ieee80211_channel *nl80211_get_valid_chan(struct wiphy *wiphy,
>  {
>         struct ieee80211_channel *chan;
>
> -       if (tb == NULL)
> +       if (!tb)
>                 return NULL;
>         chan = ieee80211_get_channel(wiphy, nla_get_u32(tb));
>         if (!chan || chan->flags & IEEE80211_CHAN_DISABLED)
> @@ -8575,7 +8575,7 @@ static int nl80211_set_tx_bitrate_mask(struct sk_buff *skb,
>                 if (band < 0 || band >= NUM_NL80211_BANDS)
>                         return -EINVAL;
>                 sband = rdev->wiphy.bands[band];
> -               if (sband == NULL)
> +               if (!sband)
>                         return -EINVAL;
>                 err = nla_parse(tb, NL80211_TXRATE_MAX, nla_data(tx_rates),
>                                 nla_len(tx_rates), nl80211_txattr_policy);
> --
> 2.8.0.rc3.226.g39d4020
>



-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
