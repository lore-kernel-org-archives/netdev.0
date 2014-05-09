From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v2] ipv4: remove inet_addr_hash_lock in
 devinet.c
Date: Thu, 08 May 2014 22:57:33 -0400 (EDT)
Message-ID: <20140508.225733.1559466564269830801.davem@davemloft.net>
References: <1399400156-993-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32896 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752123AbaEIC5e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 22:57:34 -0400
In-Reply-To: <1399400156-993-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue,  6 May 2014 11:15:56 -0700

> All the callers hold RTNL lock, so there is no need to use inet_addr_hash_lock
> to protect the hash list.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thanks a lot.
