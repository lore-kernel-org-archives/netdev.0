From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: don't wait for Tx completion on
 recovery
Date: Wed, 16 Mar 2016 19:23:49 -0400 (EDT)
Message-ID: <20160316.192349.2127685766060437016.davem@davemloft.net>
References: <1457896908-13476-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52324 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934990AbcCPXXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 19:23:51 -0400
In-Reply-To: <1457896908-13476-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Sun, 13 Mar 2016 21:21:48 +0200

> When driver has hit a parity event, HW can no longer write to host memory.
> As a result, Tx completions cannot be written to the host SB memory, and
> waiting for Tx completions eventually timeout.
> As driver is willing to delay as much as 1-2 seconds per Tx queue for its
> draining and this delay is sequential, the time to recover might greatly 
> lengthen needlessly in case the recovery is done under multi-connection
> traffic.
> 
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>

Applied.
