From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rrunner.c: fix possible memory leak in rr_init_one()
Date: Sun, 10 Mar 2013 16:43:06 -0400 (EDT)
Message-ID: <20130310.164306.1748043731464486446.davem@davemloft.net>
References: <1362767295-16334-1-git-send-email-daveo@ll.mit.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jes@trained-monkey.org
To: daveo@ll.mit.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53258 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751583Ab3CJUnC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Mar 2013 16:43:02 -0400
In-Reply-To: <1362767295-16334-1-git-send-email-daveo@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <daveo@ll.mit.edu>
Date: Fri, 8 Mar 2013 13:28:15 -0500

> From: David Oostdyk <daveo@ll.mit.edu>
> 
> In the event that register_netdev() failed, the rrpriv->evt_ring
> allocation would have not been freed.
> 
> Signed-off-by: David Oostdyk <daveo@ll.mit.edu>

Applied, thanks.
