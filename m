From: David Miller <davem@davemloft.net>
Subject: Re: mvneta: SGMII fixed-link not so fixed
Date: Thu, 17 Sep 2015 15:12:47 -0700 (PDT)
Message-ID: <20150917.151247.2129216999071943354.davem@davemloft.net>
References: <20150914103207.GH21084@n2100.arm.linux.org.uk>
	<55F6AA25.2070603@list.ru>
	<20150914114209.GL21084@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stsp@list.ru, andrew@lunn.ch, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org
To: linux@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46153 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751855AbbIQWMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 18:12:48 -0400
In-Reply-To: <20150914114209.GL21084@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Date: Mon, 14 Sep 2015 12:42:09 +0100

> Thanks, I think that will solve it.  I have to wonder why that patch
> (f8af8e6eb9509 in mainline) didn't made it into v4.2 though, as it's
> billed as a regression that occurred in the previous merge window, and
> given that it was sent in July, and we're now in September.  As it
> wasn't in v4.2, it looks like it should be a stable candidate.

The series had a whole bunch of non bug fixes in it and we were in
the final phases of 4.2, in which case I defer to applying patches
to net-next only unless I'm told otherwise.

It's up the the patch/series author to let me know that an important
regression fix is hidden in there, but they should have submitted
it seperately from the rest in that kind of situation anyways.

> David, any objections to having the stable guys pick this regression
> fix up, if not already done so?

More than this patch is needed, the one before it (3/4) instantiates
the necessary property in the DT, for example.

I can queue up the whole series for -stable if you want.
