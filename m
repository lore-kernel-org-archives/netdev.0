From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [GIT] net merged into net-next
Date: Thu, 20 Jun 2013 07:37:49 +0200
Message-ID: <1371706669.8224.2.camel@jlt4.sipsolutions.net>
References: <20130619.165713.2010181145193961339.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130619.165713.2010181145193961339.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-06-19 at 16:57 -0700, David Miller wrote:
> 
> 'net' has been merged into 'net-next', the only non-trivial merge
> conflict was in wireless.
> 
> It has to do with the bug fix that went recently into 'net' to fix the
> race that Linus discovered, which overlaps with the 'net-next' locking
> changes to nl80211.
> 
> I am pretty sure I fixed a bug in those locking changes in my merge
> commit, in that the RTNL mutex was not released in all return paths of
> nl80211_dump_wiphy().

Yes.

> Please double-check my work.

Looks good, thanks.

We had a fix for the RTNL mutex bug on its way to you (currently in
wireless-next), but this way is good too :-)

johannes


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
