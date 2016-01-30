From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netlink: not trim skb for mmaped socket when dump
Date: Fri, 29 Jan 2016 20:25:42 -0800 (PST)
Message-ID: <20160129.202542.2079689880141524449.davem@davemloft.net>
References: <20160129014549.GA28672@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: chamaken@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42300 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752145AbcA3EZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 23:25:43 -0500
In-Reply-To: <20160129014549.GA28672@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>
Date: Fri, 29 Jan 2016 10:45:50 +0900

> We should not trim skb for mmaped socket since its buf size is fixed
> and userspace will read as frame which data equals head. mmaped
> socket will not call recvmsg, means max_recvmsg_len is 0,
> skb_reserve was not called before commit: db65a3aaf29e.
> 
> Fixes: db65a3aaf29e (netlink: Trim skb to alloc size to avoid MSG_TRUNC)
> Signed-off-by: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>

Applied, thank you.
