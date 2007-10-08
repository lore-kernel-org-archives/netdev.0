From: Karsten Keil <kkeil@suse.de>
Subject: Re: 2.6.23-rc8-mm2 BUG: register_netdevice() issue as (ab)used by ISDN
Date: Mon, 8 Oct 2007 13:48:44 +0200
Message-ID: <20071008114844.GB11453@pingi.kke.suse.de>
References: <20071007120653.GA16184@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:54520 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752245AbXJHLsq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Oct 2007 07:48:46 -0400
Content-Disposition: inline
In-Reply-To: <20071007120653.GA16184@rhlx01.hs-esslingen.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 07, 2007 at 02:06:53PM +0200, Andreas Mohr wrote:
> [not necessarily a very recent regression, used 2.6.19 kernels before...]
> 
> Hi all,
> 
> wondered why my main internet server (headless!) didn't come up properly
> on a new 2.6.23-rc8-mm2
...
> as if it's the
>        BUG_ON(!dev->nd_net);
> check which caused the BUG message.

The regression comes from the net namespace patches.
Up to now in ISDN the struct netdevice is contained in struct isdn_net_dev and so
it's not allocated using alloc_netdev(), which would set the missing dev->nd_net
pointer.


-- 
Karsten Keil
SuSE Labs
ISDN and VOIP development
SUSE LINUX Products GmbH, Maxfeldstr.5 90409 Nuernberg, GF: Markus Rex, HRB 16746 (AG Nuernberg)
