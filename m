From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] ip: correctly report 802.15.4 link type
Date: Mon, 26 Jul 2010 09:35:52 -0700
Message-ID: <20100726093552.6871e27e@nehalam>
References: <1280089683-12020-1-git-send-email-jengelh@medozas.de>
	<1280089683-12020-2-git-send-email-jengelh@medozas.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43578 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753360Ab0GZQfy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jul 2010 12:35:54 -0400
In-Reply-To: <1280089683-12020-2-git-send-email-jengelh@medozas.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 25 Jul 2010 22:28:02 +0200
Jan Engelhardt <jengelh@medozas.de> wrote:

> Up until now, the "hardwpan" devices were displayed as link/[804].
> 
> Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
> ---
>  lib/ll_types.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/lib/ll_types.c b/lib/ll_types.c
> index 846cdb0..1cc46b6 100644
> --- a/lib/ll_types.c
> +++ b/lib/ll_types.c
> @@ -125,6 +125,9 @@ __PF(IEEE80211_PRISM,ieee802.11/prism)
>  #ifdef ARPHRD_IEEE80211_RADIOTAP
>  __PF(IEEE80211_RADIOTAP,ieee802.11/radiotap)
>  #endif
> +#ifdef ARPHRD_IEEE802154
> +__PF(IEEE802154, ieee802.15.4)
> +#endif
>  #ifdef ARPHRD_NONE
>  __PF(NONE, none)
>  #endif

Already fixed.
-- 
commit 4dbda0f482b8947d064b3f82992394033de6616c
Author: Stephen Hemminger <stephen.hemminger@vyatta.com>
Date:   Fri Jul 23 13:12:12 2010 -0700

    Update ARP header type table
    
    Add all current values. Since if_arp.h is included, get rid
    of ifdefs'. Make table constant.
