From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: changing dev->needed_headroom/needed_tailroom?
Date: Fri, 02 Aug 2013 06:11:22 -0700
Message-ID: <1375449082.3927.5.camel@edumazet-glaptop>
References: <1374850210.8248.59.camel@jlt4.sipsolutions.net>
	 <1375433758.24371.20.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1375433758.24371.20.camel-nDn/Rdv9kqW9Jme8/bJn5UCKIB8iOfG2tUK59QYPAWc@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-08-02 at 10:55 +0200, Ben Hutchings wrote:

> I don't think this is safe when the interface is running (even if
> carrier is off).  Some functions may read dev->needed_headroom twice and
> rely on getting the same value each time.

It should be no problem. Remaining unsafe places should be fixed.

We already had this discussion in the past, and some patches were
issued. Check commit ae641949df01b85117845bec45328eab6d6fada1
("net: Remove all uses of LL_ALLOCATED_SPACE")




--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
