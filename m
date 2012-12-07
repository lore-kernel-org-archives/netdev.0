From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: Fix check for ethtool get_link
 operation support
Date: Fri, 07 Dec 2012 14:41:46 -0500 (EST)
Message-ID: <20121207.144146.1113964976024948858.davem@davemloft.net>
References: <1354896932.2707.5.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, andy@greyhouse.net, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57996 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752952Ab2LGTls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 14:41:48 -0500
In-Reply-To: <1354896932.2707.5.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 7 Dec 2012 16:15:32 +0000

> Since commit 2c60db037034 ('net: provide a default dev->ethtool_ops')
> all devices have a non-null ethtool_ops.  Test only
> dev->ethtool_ops->get_link in both places where we care.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
