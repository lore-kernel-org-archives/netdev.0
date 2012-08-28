From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipv4: optimize tkey_mismatch
Date: Tue, 28 Aug 2012 14:56:12 -0400 (EDT)
Message-ID: <20120828.145612.2276726060621764585.davem@davemloft.net>
References: <igorm@etf.rs>
	<1346143938-17167-1-git-send-email-igorm@etf.rs>
	<1346143938-17167-2-git-send-email-igorm@etf.rs>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: igorm@etf.rs
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41002 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751983Ab2H1S4R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Aug 2012 14:56:17 -0400
In-Reply-To: <1346143938-17167-2-git-send-email-igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: igorm@etf.rs
Date: Tue, 28 Aug 2012 10:52:18 +0200

> From: Igor Maravic <igorm@etf.rs>
> 
> Optimize tkey_mismatch function by using __fls function.
> 
> Signed-off-by: Igor Maravic <igorm@etf.rs>

This will actually run slower on architectures like sparc that
don't have special instructions for __fls.

Your TOS "optimization" isn't very useful either since having
TOS routes is very rare.
