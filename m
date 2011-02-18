From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/7] IPV4 routing path simplifications
Date: Thu, 17 Feb 2011 16:11:53 -0800 (PST)
Message-ID: <20110217.161153.233687974.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57112
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752117Ab1BRALR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 19:11:17 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 283C224C087
	for <netdev@vger.kernel.org>; Thu, 17 Feb 2011 16:11:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


These cleanups and simplifications are based upon work I have been
doing over the past day analyzing why slow path route resolution
has so much overhead.

They are close to trivial and certainly not controversial so I've
added them to net-next-2.6

I know a new spin of the routing cache deletion patch is necessary so
that it applies cleanly relative to this stuff, and I'll post that in
a little bit.

Thanks.
