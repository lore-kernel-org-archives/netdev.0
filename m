From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] xfrm: add incoming interface to selector
Date: Tue, 29 Nov 2011 19:00:37 -0500 (EST)
Message-ID: <20111129.190037.1527680744377783412.davem@davemloft.net>
References: <1322511292-1413-1-git-send-email-ulrich.weber@sophos.com>
	<1322511292-1413-2-git-send-email-ulrich.weber@sophos.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ulrich.weber@Sophos.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44743 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757074Ab1K3AAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 19:00:45 -0500
In-Reply-To: <1322511292-1413-2-git-send-email-ulrich.weber@sophos.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ulrich Weber <ulrich.weber@Sophos.com>
Date: Mon, 28 Nov 2011 21:14:50 +0100

> Current implementation only allows to match for outgoing
> interface in xfrm policy database.
> 
> This replaces the user ID (which was never used) with the
> incoming interface, so both interfaces can be matched against.
> 
> Signed-off-by: Ulrich Weber <ulrich.weber@sophos.com>

This isn't safe, because we have no idea if existing users are putting
garbage there.  So your change can break things.

You'll have to add a netlink attribute or similar.
