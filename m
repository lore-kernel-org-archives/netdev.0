From: David Miller <davem@davemloft.net>
Subject: Re: BUG: unable to handle kernel paging request at 00000000d8be176d
Date: Fri, 06 Jul 2012 00:03:41 -0700 (PDT)
Message-ID: <20120706.000341.755169655502291970.davem@davemloft.net>
References: <1341556907.3265.93.camel@edumazet-glaptop>
	<20120705.234413.823095842284954048.davem@davemloft.net>
	<1341557587.3265.107.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wfg@linux.intel.com, netdev@vger.kernel.org,
	steffen.klassert@secunet.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33746 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932224Ab2GFHDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 03:03:42 -0400
In-Reply-To: <1341557587.3265.107.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 06 Jul 2012 08:53:07 +0200

> Not sure what you mean. I dont use address of pointer.

I'm talking about the cases where this caused a bug here.

Passing "struct dst_entry **dst" as an argument.

It's just stupid, and a relic of code that wants to return
a route and a locallized error at the same time.

I'm saying that in the end we should simply return "struct dst_entry
*" from such functions.

Anyways, please submit your original patch in this thread so I
can get this simple case fixed in net-next.
