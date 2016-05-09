From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 00/22] net-next: mediatek: various fixes and IRQ
 grouping
Date: Mon, 09 May 2016 12:02:27 -0400 (EDT)
Message-ID: <20160509.120227.2024353376219563839.davem@davemloft.net>
References: <1462788254-40572-1-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nbd@nbd.name, netdev@vger.kernel.org,
	linux-mediatek@lists.infradead.org
To: john@phrozen.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59704 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430AbcEIQCc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 12:02:32 -0400
In-Reply-To: <1462788254-40572-1-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Crispin <john@phrozen.org>
Date: Mon,  9 May 2016 12:03:52 +0200

> This series introduces a number of fixes that we stumbled across while
> doing more performance testing and code level reviewing. Additionally
> it improves the PHY setup code adding support for fixed phys, asymmetric
> flow control and gigabit feature advertisement. Next the series adds a
> support for IRQ grouping, allowing use to separate the IRQs onto more than
> one core using irq affinity. The last two patches wrap up the series by
> updating my email address.

This is too many patches to submit as a unit at one time.  Plus
this patch series contains lots of unrelated changes.

Split this up into logical units of related changes, and then submit
each smaller series one at a time, waiting each time for the current
series to be accepted before submitting the next one.

This is what I was trying to encourage you to do last time, I
hope what we expect is cleaerer now.

Thank you.
