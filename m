From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] sunvnet: Re-check for a VIO_DESC_READY
 data descriptor after short udelay()
Date: Tue, 02 Sep 2014 13:59:02 -0700 (PDT)
Message-ID: <20140902.135902.167580446823265395.davem@davemloft.net>
References: <20140829201809.GH14753@oracle.com>
	<20140901.204715.2121922580015092507.davem@davemloft.net>
	<54059BAA.1080307@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: raghuram.kothakota@oracle.com, netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58571 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754875AbaIBU7E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 16:59:04 -0400
In-Reply-To: <54059BAA.1080307@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Tue, 02 Sep 2014 06:27:54 -0400

> when there are no more packets coming, the extra 12 microsecond
> delay is not that big of a deal anyway.

How much other work could the cpu do in those 12 microseconds?

That's almost 3000 cpu cycles on a T4.

I understand your argument, and the fact that there are some existing
pieces of code doing this already, so I'll think about it some more.

Thanks.
