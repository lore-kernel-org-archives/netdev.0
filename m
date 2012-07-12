From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/6]: Another routing cache removal respin.
Date: Thu, 12 Jul 2012 10:42:47 -0700 (PDT)
Message-ID: <20120712.104247.616644498210685056.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58744 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030404Ab2GLRmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 13:42:50 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 262A95834FF
	for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 10:42:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


New patch at the end this time, getting rid of rt->rt_dst :-)

Most recent performance numbers:

> 1) Output route lookup: ~2150 cycles
> 2) Input route lookups: ~2600 cycles (rpfilter=0)
>                         ~3700 cycles (rpfilter=1)

How things stand now:

1) Output route lookup: ~1600 cycles
2) Input route lookups: ~2200 cycles (rpfilter=0)
                        ~3100 cycles (rpfilter=1)

Signed-off-by: David S. Miller <davem@davemloft.net>
