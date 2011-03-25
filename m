From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/2] Fix nh_saddr caching.
Date: Thu, 24 Mar 2011 18:14:13 -0700 (PDT)
Message-ID: <20110324.181413.173844730.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57988
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755410Ab1CYBNe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2011 21:13:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Julian, the following two patches should take all of the
issues we discovered the other week wrt. nh_saddr caching.

First, we use a generation ID to invalidate cache nh_saddr
settings any time a device goes up or an IP address is
added/removed.

Second, we move fa_scope up to fib_info->fib_scope, so that
we always use the correct scope when computing the cached
nh_saddr.

Please review this carefully as this is delicate code.

Thanks!
