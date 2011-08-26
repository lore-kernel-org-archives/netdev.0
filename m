From: David Miller <davem@davemloft.net>
Subject: Re: bridge: accept bridge own MAC address as local
Date: Fri, 26 Aug 2011 12:29:17 -0400 (EDT)
Message-ID: <20110826.122917.294108473242938413.davem@davemloft.net>
References: <20110812113024.GA8900@babylon>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ulrich.weber@sophos.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34415 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753795Ab1HZQ3X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2011 12:29:23 -0400
In-Reply-To: <20110812113024.GA8900@babylon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ulrich Weber <ulrich.weber@sophos.com>
Date: Fri, 12 Aug 2011 13:30:24 +0200

> bridge: accept bridge own MAC address as local
> if MAC address of bridge is manually set (BR_SET_MAC_ADDR). Otherwise
> only MAC addresses of bridge members will work if manually set.
> 
> Signed-off-by: Ulrich Weber <ulrich.weber@sophos.com>

As Stephen mentioned, the real bug is that we don't create a local
FDB entry (and get rid of the old one) when the MAC address changes.
