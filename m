From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] bridge: fix state reporting when port is disabled
Date: Thu, 08 Mar 2012 00:25:40 -0800 (PST)
Message-ID: <20120308.002540.2134888106193611323.davem@davemloft.net>
References: <20120307082514.6293.59158.stgit@localhost.localdomain>
	<20120307082522.6293.26893.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: paulius.zaleckas@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58893 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754953Ab2CHIZo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2012 03:25:44 -0500
In-Reply-To: <20120307082522.6293.26893.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paulius Zaleckas <paulius.zaleckas@gmail.com>
Date: Wed, 07 Mar 2012 10:25:22 +0200

> Now we have:
> eth0: link *down*
> br0: port 1(eth0) entered *forwarding* state
> 
> br_log_state(p) should be called *after* p->state is set
> to BR_STATE_DISABLED.
> 
> Reported-by: Zilvinas Valinskas <zilvinas@wilibox.com>
> Signed-off-by: Paulius Zaleckas <paulius.zaleckas@gmail.com>
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
