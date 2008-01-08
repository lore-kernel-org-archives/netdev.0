From: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Subject: Re: [PATCH 6/8] [PATCH] Split up rndis_host.c
Date: Tue, 8 Jan 2008 10:49:49 -0800
Message-ID: <200801081049.49764.david-b@pacbell.net>
References: <11983602942818-git-send-email-bjd@jooz.net> <200801080319.23299.david-b@pacbell.net> <1199813561.6762.13.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>, bjd-a1rhEgazXTw@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1199813561.6762.13.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tuesday 08 January 2008, Johannes Berg wrote:
> 
> > I see that the rndis_wext.c Kconfig won't kick in unless the
> > 802.11 stuff is available ... what additional dependencies
> > does that imply for a fatter rndis_host module?
> 
> No extra modules are currently required for just plain wext [1]. In the
> future, we hope to migrate stuff to cfg80211 though, which is a separate
> module.

Hmmm.  Well, go the current route then ... but come up with a good
plan to split it up later, so that connecting a typical non-wireless
RNDIS device won't incur such needless extra modules.

- Dave


> johannes
> 
> [1] mostly because all the code is simply compiled into the kernel...
> 
