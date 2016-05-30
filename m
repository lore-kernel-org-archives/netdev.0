From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH v2 06/10] nl80211: Various checkpatch.pl spacing fixes
Date: Mon, 30 May 2016 15:25:50 +1000
Message-ID: <CAGRGNgWYuEVnF7OG4GKJrnNNkn8DWaAor=ebbiwRbTZBP8qn5Q@mail.gmail.com>
References: <cover.1464576022.git.kirtika.ruchandani@gmail.com> <80c4512b4c5ca1f26ecda9785a456c4d0cf4f937.1464576022.git.kirtika.ruchandani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Johannes Berg <johannes@sipsolutions.net>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Tina Ruchandani <ruchandani.tina@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:34124 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753877AbcE3F0K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2016 01:26:10 -0400
In-Reply-To: <80c4512b4c5ca1f26ecda9785a456c4d0cf4f937.1464576022.git.kirtika.ruchandani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

On Mon, May 30, 2016 at 12:53 PM, Kirtika Ruchandani
<kirtika.ruchandani@gmail.com> wrote:
> This patch fixes the following spacing issues reported
> by checkpatch.pl -
> - space preferred around that <operator>
> - no space needed after cast.
> - Alignment should match open parenthesis
> - suspect code indent for conditional statements
> - Statements should start on a tabstop
>
> This patch also contains two hunks to fix 'line over 80 characters',
> that are spacing related.
> All other instances of that warning have been ignored.
>
> Signed-off-by: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>

Looks right to me except for one minor point:

> ---
>  net/wireless/nl80211.c | 103 ++++++++++++++++++++++++++-----------------------
>  1 file changed, 54 insertions(+), 49 deletions(-)
>
> diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
> index 11cbf0b..ad7cdce 100644
> --- a/net/wireless/nl80211.c
> +++ b/net/wireless/nl80211.c
> @@ -1735,8 +1735,9 @@ static int nl80211_send_wiphy(struct cfg80211_registered_device *rdev,
>                                rdev->wiphy.max_num_csa_counters))
>                         goto nla_put_failure;
>
> -               if (rdev->wiphy.regulatory_flags & REGULATORY_WIPHY_SELF_MANAGED &&
> -                   nla_put_flag(msg, NL80211_ATTR_WIPHY_SELF_MANAGED_REG))
> +               if ((rdev->wiphy.regulatory_flags &
> +                    REGULATORY_WIPHY_SELF_MANAGED) &&
> +                    nla_put_flag(msg, NL80211_ATTR_WIPHY_SELF_MANAGED_REG))

Adding the brackets around the & expression doesn't look spacing
related to me. What's the exact warning this is fixing?

>                         goto nla_put_failure;
>
>                 if (nla_put(msg, NL80211_ATTR_EXT_FEATURES,

Thanks,

-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
