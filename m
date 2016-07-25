From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: ipv6: Always leave anycast and multicast
 groups on link down
Date: Mon, 25 Jul 2016 11:17:00 -0700 (PDT)
Message-ID: <20160725.111700.850560273619896723.davem@davemloft.net>
References: <1469208731-1085-1-git-send-email-mmanning@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mmanning@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43612 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751962AbcGYSRB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 14:17:01 -0400
In-Reply-To: <1469208731-1085-1-git-send-email-mmanning@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Manning <mmanning@brocade.com>
Date: Fri, 22 Jul 2016 18:32:11 +0100

> Default kernel behavior is to delete IPv6 addresses on link
> down, which entails deletion of the multicast and the
> subnet-router anycast addresses. These deletions do not
> happen with sysctl setting to keep global IPv6 addresses on
> link down, so every link down/up causes an increment of the
> anycast and multicast refcounts. These bogus refcounts may
> stop these addrs from being removed on subsequent calls to
> delete them. The solution is to leave the groups for the
> multicast and subnet anycast on link down for the callflow
> when global IPv6 addresses are kept.
> 
> Fixes: f1705ec197e7 ("net: ipv6: Make address flushing on ifdown optional")
> Signed-off-by: Mike Manning <mmanning@brocade.com>

Applied and queued up for -stable, thanks.
