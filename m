From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Subject: Re: [PATCH v2 1/4] cfg80211:  Add framework to support ethtool
 stats.
Date: Fri, 16 Mar 2012 20:50:56 +0000
Message-ID: <1331931056.2504.7.camel@bwh-desktop.uk.solarflarecom.com>
References: <1331927952-8706-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1331927952-8706-1-git-send-email-greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-03-16 at 12:59 -0700, greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org wrote:
> From: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
> 
> Signed-off-by: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
> ---
> 
> v2:  Fix formatting issues, add kdoc comments
> 
> :100644 100644 9ed8021... f5c8e02... M	include/net/cfg80211.h
> :100644 100644 9bde4d1... 7eecdf4... M	net/wireless/ethtool.c
>  include/net/cfg80211.h |   14 ++++++++++++++
>  net/wireless/ethtool.c |   29 +++++++++++++++++++++++++++++
>  2 files changed, 43 insertions(+), 0 deletions(-)
> 
> diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
> index 9ed8021..f5c8e02 100644
> --- a/include/net/cfg80211.h
> +++ b/include/net/cfg80211.h
> @@ -1491,6 +1491,13 @@ struct cfg80211_gtk_rekey_data {
>   *	later passes to cfg80211_probe_status().
>   *
>   * @set_noack_map: Set the NoAck Map for the TIDs.
> + *
> + * @get_et_sset_count:  Ethtool API to get string-set count.
> + *
> + * @get_et_stats:  Ethtool API to get a set of u64 stats.
> + *
> + * @get_et_strings:  Ethtool API to get a set of strings to describe stats
> + *	and perhaps other supported types of ethtool data-sets.
[...]

Please add an explicit reference to struct ethtool_ops, where the
semantics of these operations should be described in more detail.
(There isn't currently as much detail as there should be, but any extra
information is going to be added there and not here.)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
