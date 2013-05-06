From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fib_trie: no need to delay vfree()
Date: Mon, 06 May 2013 11:08:44 -0400 (EDT)
Message-ID: <20130506.110844.1588607407608671815.davem@davemloft.net>
References: <20130506020346.GK25399@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: viro@ZenIV.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58937 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753690Ab3EFPIr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 May 2013 11:08:47 -0400
In-Reply-To: <20130506020346.GK25399@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Mon, 6 May 2013 03:03:46 +0100

> Now that vfree() can be called from interrupt contexts, there's no
> need to play games with schedule_work() to escape calling vfree()
> from RCU callbacks.
> 
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>

Applied.
