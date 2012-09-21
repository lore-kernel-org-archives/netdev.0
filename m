From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: sysctl for initial receive window
Date: Fri, 21 Sep 2012 14:48:08 -0400 (EDT)
Message-ID: <20120921.144808.1893006476597754774.davem@davemloft.net>
References: <1348241111.2669.580.camel@edumazet-glaptop>
	<20120921.135601.254379488076661898.davem@davemloft.net>
	<1348252326.3103.90.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, nanditad@google.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51606 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757542Ab2IUSsM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 14:48:12 -0400
In-Reply-To: <1348252326.3103.90.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Fri, 21 Sep 2012 20:32:06 +0200

> On Fri, 2012-09-21 at 13:56 -0400, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Fri, 21 Sep 2012 17:25:11 +0200
>> 
>> I would only let this in if you hard limited the setting to it's
>> current setting, 10.  So people could decrease it.
> 
> The would defeat the purpose of the patch.  Perhaps we could, allow a
> sensible max... (but this max is already being controlled as described).

Any new max which is truly sensible, could be the new default, and we
would apply the same amount of vetting for such a thing.
