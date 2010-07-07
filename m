From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 2/2] sfc: Implement 64-bit net device statistics on
 all architectures
Date: Wed, 07 Jul 2010 12:56:57 -0700 (PDT)
Message-ID: <20100707.125657.90809263.davem@davemloft.net>
References: <1276017672.2185.12.camel@achroite.uk.solarflarecom.com>
	<1278353780.2877.620.camel@edumazet-laptop>
	<1278354682.2877.639.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, shemminger@vyatta.com, arnd@arndb.de,
	netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59532
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755716Ab0GGT4n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jul 2010 15:56:43 -0400
In-Reply-To: <1278354682.2877.639.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 05 Jul 2010 20:31:22 +0200

> One other way would be to add a rtnl_link_stats64 param to
> ndo_get_stats64() method, and ask drivers to copy their stats in this
> zone, instead of returning &dev->stats64 or something...
> 
> And also change dev_get_stats() with this new parameter.
> 
> Each caller would use a private copy, with no risk of concurrent
> updates.

If this can be reliably be made at all call sites, I think such
an approach is preferable.
