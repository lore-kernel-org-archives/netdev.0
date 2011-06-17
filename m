From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: avoid using uninitialized variable
Date: Thu, 16 Jun 2011 23:10:18 -0400 (EDT)
Message-ID: <20110616.231018.84570655636629416.davem@davemloft.net>
References: <20110613181212.571f8e76@s6510.ftrdhcpuser.net>
	<BANLkTi=jw5=9LcwxnXW6xNkF4RbFhHaB55Au=oDhn1yYWf53dA@mail.gmail.com>
	<20110614000230.4166a1ae@s6510.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gthelen@google.com, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51449 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754836Ab1FQDKy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2011 23:10:54 -0400
In-Reply-To: <20110614000230.4166a1ae@s6510.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 14 Jun 2011 00:02:30 -0400

> In my experience if phy reads once successfully, it is going
> to read every time. If there is a problem it only happens on
> the first access (powered off, bad timing, etc).

It also happens when the PHY can't get a response for a certain
register, for whatever reason, before internal hw timeouts trigger.

Please, check all MII accesses.  That's what I do in every driver
I've written.

