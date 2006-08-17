From: Jiri Benc <jbenc@suse.cz>
Subject: Re: 802.11 headers
Date: Thu, 17 Aug 2006 14:34:43 +0200
Message-ID: <20060817143443.77ede2e5@griffin.suse.cz>
References: <1155800899.3653.13.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jouni Malinen <jkm@devicescape.com>,
	David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:49359 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S932295AbWHQMep (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2006 08:34:45 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1155800899.3653.13.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 17 Aug 2006 09:48:19 +0200, Johannes Berg wrote:
> My current thoughts:
>  - net/d80211_common.h can die sometime soon due to being replaced with
>    linux/nl80211.h (to be published today).
>  - net/d80211_mgmt.h needs cleaning up (I know Michael has been doing
>    some of that), and then should probably be renamed to
>    linux/ieee80211.h and be userland-visible, and contain a bunch of
>    other frame definitions as well. A bit like net/ieee80211.h now,
>    though more protocol-centric.
>  - net/ieee80211_radiotap.h should be userland-visible, and hence
>    linux/radiotap.h or such.
>  - net/d80211_shared.h probably has the same fate as

d80211_shared.h should probably be merged into d80211.h.

>    net/d80211_common.h, except for the _RATE_* thingies, but I'm not
>    sure why they should be userland-visible.
>  - net/d80211.h can stay there as-is, it's in-kernel only API.
>  
> Or put another way, my suggestions:
>  - put all in-kernel API (for drivers) into net/d80211.h
>  - put stuff defined in the IEEE 802.11 specification series into
>    linux/ieee80211.h, make user-visible (headers-y in Kbuild!). This
>    serves just as a reference. It's not really necessary that the kernel
>    ships this, but we need it in the kernel and probably won't be
>    pulling it from some other source. Besides, I wouldn't know where
>    else to maintain it.
>  - radiotap simply moves to linux/ and gets to be userland-visible. Of
>    course, d80211 should actually start using it too ;)
>  - all the other userland stuff seems to be configuration related and
>    hence moves over to linux/nl80211.h
> 
> Comments?

I like this proposal.

 Jiri

-- 
Jiri Benc
SUSE Labs
