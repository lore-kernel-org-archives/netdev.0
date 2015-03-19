From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: 8021q: additionally pass SIOCSHWTSTAMP ioctl flag
 to, the real device
Date: Thu, 19 Mar 2015 14:50:36 -0400 (EDT)
Message-ID: <20150319.145036.2014651675915638641.davem@davemloft.net>
References: <550AA024.8030606@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: martin.gerbershagen@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49182 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750965AbbCSSuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 14:50:39 -0400
In-Reply-To: <550AA024.8030606@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Gerbershagen <martin.gerbershagen@nokia.com>
Date: Thu, 19 Mar 2015 11:08:36 +0100

> 
>    If vlan devices were used, hardware timestamping did not work. The
>    problem was that the SIOCSHWTSTAMP ioctl flag was not passed to the real
>    device. This is fixed with this patch.
> 
>    Signed-off-by: Martin Gerbershagen <martin.gerbershagen@nokia.com>

Please only submit patches against current sources.

Not only is the SIOCSHWTSTAMP there in vlan_dev_ioctl() already, unlike
your patch SIOCGHWTSTAMP is handled and passed down as well.

In fact it's been that way since 3.17 which was released in October 2014,
that's 5 months ago.

You want everyone reading your patch posting to care enough to review
it properly and integrate it if it is valid, yet you don't care enough
about your own change and the time invested by the developers here
reviewing your work to base your work againt current sources?
