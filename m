From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2010-01-12
Date: Tue, 12 Jan 2010 21:42:59 -0800 (PST)
Message-ID: <20100112.214259.169429418.davem@davemloft.net>
References: <20100112163924.GA2987@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100112163924.GA2987-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Tue, 12 Jan 2010 11:39:24 -0500

> I apologize that it has been a while (i.e. too long) since my last pull
> request.  I was giving this round extra time to bake...
> 
> Most of these are the usual one-liners and/or isolated fixes.  One
> exception is "mac80211: fix skb buffering issue" from Johannes.  The
> changelog describes the issue, but basically when the master netdev got
> removed our multiqueue support went along with it.  This led to some
> regressions that manifested as queueing/congestion problems.  The fix
> from Johannes adds multiqueue support to the current mac80211
> implementation.  Because this was a significant (but IMHO necessary)
> change, I allowed this to bake over the last week or so and collected a
> few fixes on top of that change in the process.
> 
> One other change of note is an EEPROM checksum change for Atheros
> devices.  It seems there were some devices that handled their checksum
> differently and they were being disabled after "ath5k: enable EEPROM
> checksum check".  This has also been baking for a while and no problems
> have been reported.

Pulled, thanks John.

> Finally, thanks for the git advice after the last pull request!  One
> more incremental step in improving my workflow... :-)

Any time :)
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
