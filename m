From: David Miller <davem@davemloft.net>
Subject: Re: invalid requirement from ethtool?
Date: Mon, 15 Aug 2011 13:49:46 -0700 (PDT)
Message-ID: <20110815.134946.2305055687888184889.davem@davemloft.net>
References: <20110726124222.GA4842@mtldesk30>
	<1313429040.2731.17.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eli@dev.mellanox.co.il, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48396 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752544Ab1HOUw3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2011 16:52:29 -0400
In-Reply-To: <1313429040.2731.17.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 15 Aug 2011 18:24:00 +0100

> David, I know you maintained tg3 for some time so I assume you have a
> hardware reference.  Can you confirm whether a value of 1 in
> HOSTCC_{RX,TX}MAX_FRAMES results in an interrupt after 1 completion or
> after 2 completions?

A value of 1 results in an interrupt after 1 completion.

If you put a zero there, the packet count comparison never triggers.
