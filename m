From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull-request: mac80211 2016-10-18
Date: Tue, 18 Oct 2016 10:26:45 -0400 (EDT)
Message-ID: <20161018.102645.77065965118492040.davem@davemloft.net>
References: <1476774058-9279-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1476774058-9279-1-git-send-email-johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Tue, 18 Oct 2016 09:00:57 +0200

> As I mention in the tag message, the most urgent fix here is for
> the VMAP_STACK vs. software crypto usage. I ended up applying Ard's
> fix that dynamically allocates everything in one go, perhaps we'll
> find a better solution in the future, but in the meantime this will
> get things working again (rather than crashing or getting BUG_ON),
> and normally it's a rarely used code path since hardware crypto is
> used for almost all devices.
> 
> Please pull, or let me know if there's any problem.

Pulled, thanks Johannes.
