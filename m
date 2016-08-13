From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv6: Do not keep IPv6 addresses when IPv6 is
 disabled
Date: Sat, 13 Aug 2016 15:14:39 -0700 (PDT)
Message-ID: <20160813.151439.1969888908743414343.davem@davemloft.net>
References: <1470999758-11535-1-git-send-email-mmanning@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mmanning@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35566 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753186AbcHNIx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2016 04:53:29 -0400
In-Reply-To: <1470999758-11535-1-git-send-email-mmanning@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Manning <mmanning@brocade.com>
Date: Fri, 12 Aug 2016 12:02:38 +0100

> If IPv6 is disabled when the option is set to keep IPv6
> addresses on link down, userspace is unaware of this as
> there is no such indication via netlink. The solution is to
> remove the IPv6 addresses in this case, which results in
> netlink messages indicating removal of addresses in the
> usual manner. This fix also makes the behavior consistent
> with the case of having IPv6 disabled first, which stops
> IPv6 addresses from being added.
> 
> Fixes: f1705ec197e7 ("net: ipv6: Make address flushing on ifdown optional")
> Signed-off-by: Mike Manning <mmanning@brocade.com>

Applied and queued up for -stable, thanks.
