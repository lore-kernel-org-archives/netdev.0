From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH 1/2] include/net/cfg80211.h: Fix issue of make htmldocs
Date: Wed, 09 Nov 2011 18:01:09 -0800
Message-ID: <4EBB3065.9050707@xenotime.net>
References: <1320871572-3430-1-git-send-email-marcos.mage@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: johannes@supsolutions.net, davem@davemloft.net,
	netdev@vger.kernel.org
To: Marcos Paulo de Souza <marcos.mage@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oproxy5-pub.bluehost.com ([67.222.38.55]:49894 "HELO
	oproxy5-pub.bluehost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751907Ab1KJCCY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 21:02:24 -0500
In-Reply-To: <1320871572-3430-1-git-send-email-marcos.mage@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/09/2011 12:46 PM, Marcos Paulo de Souza wrote:
> Make documentation of member sta_modify_mask of struct
> station_parameters and sta_flags of struct station_info.
> 
> Signed-off-by: Marcos Paulo de Souza <marcos.mage@gmail.com>

Thanks, but Johannes has already posted a patch for this
(to linux-wireless).

> ---
>  include/net/cfg80211.h |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
> index 92cf1c2..bbf6bf7 100644
> --- a/include/net/cfg80211.h
> +++ b/include/net/cfg80211.h
> @@ -447,6 +447,7 @@ enum station_parameters_apply_mask {
>   *	(bitmask of BIT(NL80211_STA_FLAG_...))
>   * @sta_flags_set: station flags values
>   *	(bitmask of BIT(NL80211_STA_FLAG_...))
> + * @sta_modify_mask: apply new uAPSD parameters
>   * @listen_interval: listen interval or -1 for no change
>   * @aid: AID or zero for no change
>   * @plink_action: plink action to take
> @@ -606,6 +607,7 @@ struct sta_bss_parameters {
>   * @tx_failed: number of failed transmissions (retries exceeded, no ACK)
>   * @rx_dropped_misc:  Dropped for un-specified reason.
>   * @bss_param: current BSS parameters
> + * @sta_flags: Station flags mask/set
>   * @generation: generation number for nl80211 dumps.
>   *	This number should increase every time the list of stations
>   *	changes, i.e. when a station is added or removed, so that


-- 
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
