From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Minor logic clean-up in ipv4_mtu
Date: Fri, 31 Aug 2012 16:23:14 -0400 (EDT)
Message-ID: <20120831.162314.846637293917606779.davem@davemloft.net>
References: <20120827162930.2969.96733.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53270 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754860Ab2HaUXQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2012 16:23:16 -0400
In-Reply-To: <20120827162930.2969.96733.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Mon, 27 Aug 2012 09:30:01 -0700

> In ipv4_mtu there is some logic where we are testing for a non-zero value
> and a timer expiration, then setting the value to zero, and then testing if
> the value is zero we set it to a value based on the dst.  Instead of
> bothering with the extra steps it is easier to just cleanup the logic so
> that we set it to the dst based value if it is zero or if the timer has
> expired.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

Applied to net-next, thanks.
