From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] amd-xgbe: Prevent Tx cleanup stall
Date: Tue, 09 Dec 2014 14:48:21 -0500 (EST)
Message-ID: <20141209.144821.577727845317298785.davem@davemloft.net>
References: <20141204175235.11100.52433.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38045 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752262AbaLITsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 14:48:24 -0500
In-Reply-To: <20141204175235.11100.52433.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Thu, 4 Dec 2014 11:52:35 -0600

> When performing Tx cleanup, the dirty index counter is compared to the
> current index counter as one of the tests used to determine when to stop
> cleanup. The "less than" test will fail when the current index counter
> rolls over to zero causing cleanup to never occur again. Update the test
> to a "not equal" to avoid this situation.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>

Applied.
