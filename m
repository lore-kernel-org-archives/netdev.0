From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] ipv4: remove inet_addr_hash_lock in devinet.c
Date: Mon, 05 May 2014 16:35:24 -0400 (EDT)
Message-ID: <20140505.163524.1995679741348650063.davem@davemloft.net>
References: <1399315610-28771-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33480 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755726AbaEEUf0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 16:35:26 -0400
In-Reply-To: <1399315610-28771-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon,  5 May 2014 11:46:50 -0700

> All the callers hold RTNL lock, so there is no need to use inet_addr_hash_lock
> to protect the hash list.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

If you are going to do this, please add ASSERT_RTNL() to these two locations
at the same time.

Thank you.
