From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] mlx4 driver encapsulation/steering fixes
Date: Thu, 30 Oct 2014 19:49:50 -0400 (EDT)
Message-ID: <20141030.194950.2037189214723895940.davem@davemloft.net>
References: <1414677568-28409-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, matanb@mellanox.com, amirv@mellanox.com,
	saeedm@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32808 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751131AbaJ3Xtx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 19:49:53 -0400
In-Reply-To: <1414677568-28409-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu, 30 Oct 2014 15:59:26 +0200

> The 1st patch fixes a bug in the TX path that supports offloading the 
> TX checksum of (VXLAN) encapsulated TCP packets. It turns out that the 
> bug is revealed only when the receiver runs in non-offloaded mode, so
> we somehow missed it so far... please queue it for -stable >= 3.14 
> 
> The 2nd patch makes sure not to leak steering entry on error flow, 
> please queue it to 3.17-stable 

Applied and queue up for -stable.
