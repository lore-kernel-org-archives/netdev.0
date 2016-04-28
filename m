From: David Miller <davem@davemloft.net>
Subject: Re: [patch] tipc: remove an unnecessary NULL check
Date: Thu, 28 Apr 2016 16:54:54 -0400 (EDT)
Message-ID: <20160428.165454.1105669734912206052.davem@davemloft.net>
References: <20160427080528.GA22469@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, ying.xue@windriver.com,
	netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42204 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752685AbcD1Uy5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 16:54:57 -0400
In-Reply-To: <20160427080528.GA22469@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 27 Apr 2016 11:05:28 +0300

> This is never called with a NULL "buf" and anyway, we dereference 's' on
> the lines before so it would Oops before we reach the check.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied to net-next, thanks.
