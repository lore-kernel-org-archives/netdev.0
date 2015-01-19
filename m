From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next v5 0/4] netns: allow to identify peer netns
Date: Mon, 19 Jan 2015 14:16:53 -0500 (EST)
Message-ID: <20150119.141653.1430392722084939705.davem@davemloft.net>
References: <87wq7g831b.fsf@x220.int.ebiederm.org>
	<1421331078-21622-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org,
	cwang-xCSkyg8dI+0RB7SZvlqPiA@public.gmane.org
To: nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1421331078-21622-1-git-send-email-nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Date: Thu, 15 Jan 2015 15:11:14 +0100

> The goal of this serie is to be able to multicast netlink messages with an
> attribute that identify a peer netns.
> This is needed by the userland to interpret some information contained in
> netlink messages (like IFLA_LINK value, but also some other attributes in case
> of x-netns netdevice (see also
> http://thread.gmane.org/gmane.linux.network/315933/focus=316064 and
> http://thread.gmane.org/gmane.linux.kernel.containers/28301/focus=4239)).
> 
> Ids of peer netns can be set by userland via a new rtnl cmd RTM_NEWNSID. When
> the kernel needs an id for a peer (for example when advertising a new x-netns
> interface via netlink), if the user didn't allocate an id, one will be
> automatically allocated.
> These ids are stored per netns and are local (ie only valid in the netns where
> they are set). To avoid allocating an int for each peer netns, I use
> idr_for_each() to retrieve the id of a peer netns. Note that it will be possible
> to add a table (struct net -> id) later to optimize this lookup if needed.
> 
> Patch 1/4 introduces the rtnetlink API mechanism to set and get these ids.
> Patch 2/4 and 3/4 implements an example of how to use these ids when advertising
> information about a x-netns interface.
> And patch 4/4 shows that the netlink messages can be symetric between a GET and
> a SET.
 ...

Seires applied, thanks.
