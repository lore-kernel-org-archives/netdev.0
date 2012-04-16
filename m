From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH v3] mac80211: Support on-channel scan option.
Date: Mon, 16 Apr 2012 10:33:00 -0700
Message-ID: <4F8C57CC.4090505@sipsolutions.net>
References: <1334248689-23018-1-git-send-email-greearb@candelatech.com> (sfid-20120412_183929_638765_C70D881D)
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1334248689-23018-1-git-send-email-greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org> (sfid-20120412_183929_638765_C70D881D)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Did you test it?

> +		/* If we are scanning only on the current channel, then
> +		 * we do not need to stop normal activities
> +		 */
> +		unsigned long next_delay;
> +
> +		__set_bit(SCAN_ONCHANNEL_SCANNING,&local->scanning);
> +		ieee80211_recalc_idle(local);
> +		/* Notify driver scan is starting, keep order of operations
> +		 * same as normal software scan, in case that matters. */
> +		drv_sw_scan_start(local);
> +		ieee80211_configure_filter(local); /* accept probe-responses */
> +		/* We need to ensure power level is at max for scanning. */
> +		ieee80211_hw_config(local, 0);

a few blank lines would be nice :)

> +		if ((req->channels[0]->flags&
> +		     IEEE80211_CHAN_PASSIVE_SCAN) ||
> +		    !local->scan_req->n_ssids) {

That formatting is a bit off it seems. Or is that just my mailer?

johannes
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
