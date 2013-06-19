From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [GIT] net merged into net-next
Date: Wed, 19 Jun 2013 16:57:13 -0700 (PDT)
Message-ID: <20130619.165713.2010181145193961339.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


'net' has been merged into 'net-next', the only non-trivial merge
conflict was in wireless.

It has to do with the bug fix that went recently into 'net' to fix the
race that Linus discovered, which overlaps with the 'net-next' locking
changes to nl80211.

I am pretty sure I fixed a bug in those locking changes in my merge
commit, in that the RTNL mutex was not released in all return paths of
nl80211_dump_wiphy().

Please double-check my work.

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
