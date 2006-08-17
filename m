From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [d80211 rfc] link master interface from wiphy
Date: Thu, 17 Aug 2006 09:18:08 +0200
Message-ID: <1155799088.3653.1.camel@ux156>
References: <44E02F41.2060300@sipsolutions.net>
	 <44E03051.8030808@sipsolutions.net>
	 <20060816190520.57cb676f@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jouni Malinen <jkm@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:17094 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751217AbWHQHSY
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 03:18:24 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060816190520.57cb676f@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-08-16 at 19:05 +0200, Jiri Benc wrote:

> Btw, we will probably need some way to ask d80211 about all interfaces
> belonging to given wiphy anyway. Crawling all network interfaces and
> searching for correct wiphy symlinks is probably not the best way. I
> think a new netlink interface can be used for this.

Yeah, that should be fairly easy.

> > wpa_supplicant could use this, I guess. I think 
> > another link to wlan#ap should be created (or does wpa_supplicant set 
> > the name of that so it knows which one it will get?), or something like 
> > that anyway.
> 
> wmgmt# will go away in future. There is an ioctl to get its ifindex, so
> no need for the link.

Right, Jouni pointed that out already. Forget what I said :) Besides,
I'm already working hard on deprecating it :P

> What do you mean by "making the virtual devices all children of the
> wiphy"? Currently, all virtual devices (of one physical device) have the
> same pointer to ieee80211_local in their net_dev structure and pointers
> to them are stored in the linked list in ieee80211_local.

I was wondering why they in sysfs have their device link set to the
physical device instead of the master wiphy. I'm not sure if the latter
makes sense though.

> Do you know about /sys/class/net/X/wiphy symlinks?

yes, I'm actually using them :)

Thanks,
johannes
