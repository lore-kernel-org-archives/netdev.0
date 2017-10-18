From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] netlink: use NETLINK_CB(in_skb).sk instead of looking
 it up
Date: Wed, 18 Oct 2017 12:21:24 +0100 (WEST)
Message-ID: <20171018.122124.1275281623792997169.davem@davemloft.net>
References: <20171016145749.31793-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        ebiederman-1v8oiQdgUNlBDgjK7y7TUQ@public.gmane.org, johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20171016145749.31793-1-johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Mon, 16 Oct 2017 16:57:49 +0200

> From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> 
> When netlink_ack() reports an allocation error to the sending
> socket, there's no need to look up the sending socket since
> it's available in the SKB's CB. Use that instead of going to
> the trouble of looking it up.
> 
> Note that the pointer is only available since Eric Biederman's
> commit 3fbc290540a1 ("netlink: Make the sending netlink socket availabe in NETLINK_CB")
> which is far newer than the original lookup code (Oct 2003)
> (though the field was called 'ssk' in that commit and only got
> renamed to 'sk' later, I'd actually argue 'ssk' was better - or
> perhaps it should've been 'source_sk' - since there are so many
> different 'sk's involved.)
> 
> Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Applied to net-next.
