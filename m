From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netlink: hold nl_sock_hash_lock during diag dump
Date: Wed, 06 Aug 2014 19:18:24 -0700 (PDT)
Message-ID: <20140806.191824.1719351238922873517.davem@davemloft.net>
References: <20140806195127.GA26832@casper.infradead.org>
	<CAHA+R7OB_gTYPKtqw-iry+nfkTbmApw4GPpeKjqfXugcit4Guw@mail.gmail.com>
	<20140806231847.GA3703@casper.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cwang@twopensource.com, avagin@gmail.com, netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45888 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754550AbaHGCSZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 22:18:25 -0400
In-Reply-To: <20140806231847.GA3703@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 7 Aug 2014 00:18:47 +0100

> [PATCH net] netlink: hold nl_sock_hash_lock during diag dump
> 
> Although RCU protection would be possible during diag dump, doing
> so allows for concurrent table mutations which can render the
> in-table offset between individual Netlink messages invalid and
> thus cause legitimate sockets to be skipped in the dump.
> 
> Since the diag dump is relatively low volume and consistency is
> more important than performance, the table mutex is held during
> dump.
> 
> Reported-by: Andrey Wagin <avagin@gmail.com>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> Fixes: e341694e3eb57fc ("netlink: Convert netlink_lookup() to use RCU protected hash table")

Applied, thanks Thomas.
