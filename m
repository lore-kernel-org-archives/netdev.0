From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netlink: mmap: fix tx type check
Date: Sun, 23 Aug 2015 16:06:15 -0700 (PDT)
Message-ID: <20150823.160615.1547348326644209495.davem@davemloft.net>
References: <55CDBC84.8020605@iogearbox.net>
	<55CDC51D.1060204@iogearbox.net>
	<20150820034353.GA728@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, fw@strlen.de
To: chamaken@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47040 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751273AbbHWXGQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2015 19:06:16 -0400
In-Reply-To: <20150820034353.GA728@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>
Date: Thu, 20 Aug 2015 12:43:53 +0900

> I can't send netlink message via mmaped netlink socket since
> 
>     commit: a8866ff6a5bce7d0ec465a63bc482a85c09b0d39
>     netlink: make the check for "send from tx_ring" deterministic
> 
> msg->msg_iter.type is set to WRITE (1) at
> 
>     SYSCALL_DEFINE6(sendto, ...
>         import_single_range(WRITE, ...
>             iov_iter_init(1, WRITE, ...
> 
> call path, so that we need to check the type by iter_is_iovec()
> to accept the WRITE.
> 
> Signed-off-by: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>

Applied, thanks.
