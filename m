From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] tipc: fix a memleak when sending data
Date: Tue, 08 Jul 2014 16:10:22 -0700 (PDT)
Message-ID: <20140708.161022.1576638989039162794.davem@davemloft.net>
References: <1404693530-2531-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54929 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151AbaGHXKX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 19:10:23 -0400
In-Reply-To: <1404693530-2531-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Sun,  6 Jul 2014 20:38:50 -0400

> From: Erik Hugne <erik.hugne@ericsson.com>
> 
> This fixes a regression bug caused by:
> 067608e9d019d6477fd45dd948e81af0e5bf599f ("tipc: introduce direct
> iovec to buffer chain fragmentation function")
> 
> If data is sent on a nonblocking socket and the destination link
> is congested, the buffer chain is leaked. We fix this by freeing
> the chain in this case.
> 
> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied, thank you.
