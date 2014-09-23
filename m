From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] vxlan: Fix bug introduced by commit acbf74a76300
Date: Tue, 23 Sep 2014 15:33:21 -0400 (EDT)
Message-ID: <20140923.153321.1728757555128556617.davem@davemloft.net>
References: <1411461891-4442-1-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: azhou@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37436 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753540AbaIWTd1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 15:33:27 -0400
In-Reply-To: <1411461891-4442-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Zhou <azhou@nicira.com>
Date: Tue, 23 Sep 2014 01:44:51 -0700

> Commit acbf74a76300 ("vxlan: Refactor vxlan driver to make use of the common UDP tunnel functions." introduced a bug in vxlan_xmit_one()
> function, causing it to transmit Vxlan packets without proper
> Vxlan header inserted. The change was not needed in the first
> place. Revert it.
> 
> Reported-by: Tom Herbert <therbert@google.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Andy Zhou <azhou@nicira.com>

Applied, thanks Andy.
