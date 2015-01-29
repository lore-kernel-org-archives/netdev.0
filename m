From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: remove sock_iocb
Date: Wed, 28 Jan 2015 23:22:11 -0800 (PST)
Message-ID: <20150128.232211.1157376728217761804.davem@davemloft.net>
References: <1422464693-7827-1-git-send-email-hch@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hch@lst.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36820 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755742AbbA2HWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 02:22:12 -0500
In-Reply-To: <1422464693-7827-1-git-send-email-hch@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Hellwig <hch@lst.de>
Date: Wed, 28 Jan 2015 18:04:53 +0100

> The sock_iocb structure is allocate on stack for each read/write-like
> operation on sockets, and contains various fields of which only the
> embedded msghdr and sometimes a pointer to the scm_cookie is ever used.
> Get rid of the sock_iocb and put a msghdr directly on the stack and pass
> the scm_cookie explicitly to netlink_mmap_sendmsg.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Looks good, applied, thanks.
