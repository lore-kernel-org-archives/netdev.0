From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: check return value of ipv6_dev_get_saddr()
Date: Mon, 05 Mar 2012 16:45:46 -0500 (EST)
Message-ID: <20120305.164546.1067133150248424694.davem@davemloft.net>
References: <20120305145244.GA10621@WS-uweber>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ulrich.weber@Sophos.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56619 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754111Ab2CEVpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 16:45:51 -0500
In-Reply-To: <20120305145244.GA10621@WS-uweber>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ulrich Weber <ulrich.weber@Sophos.com>
Date: Mon, 5 Mar 2012 15:52:44 +0100

> otherwise source IPv6 address of ICMPV6_MGM_QUERY packet
> might be random junk if IPv6 is disabled on interface or
> link-local address is not yet ready (DAD).
> 
> Signed-off-by: Ulrich Weber <ulrich.weber@sophos.com>

Applied and queued up for -stable, thanks.
