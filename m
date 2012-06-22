From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 4/6] mac80211: clean up debugging
Date: Fri, 22 Jun 2012 07:37:08 -0700
Message-ID: <1340375828.31821.11.camel@joe2Laptop>
References: <1340370882-9258-1-git-send-email-johannes@sipsolutions.net>
	 <1340370882-9258-5-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1340370882-9258-5-git-send-email-johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-06-22 at 15:14 +0200, Johannes Berg wrote:
> From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> 
> There are a few things that make the debugging
> in mac80211 painful:
>  * pr_debug makes it require *both* Kconfig and
>    dynamic configuration -- move to pr_info

pr_info can clutter the log.

>  * the macros still need trailing newlines

That's not a bad thing.


> @@ -317,7 +318,7 @@ ieee80211_agg_splice_packets(struct ieee80211_sub_if_data *sdata,
>  	ieee80211_stop_queue_agg(sdata, tid);
>  
>  	if (WARN(!tid_tx, "TID %d gone but expected when splicing aggregates"
> -			  " from the pending queue\n", tid))
> +			  " from the pending queue", tid))


defective.

Don't remove newlines in single modules.

Using a single style _with_ a newline limits defects and
limits the likely misuse in other styles.


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
