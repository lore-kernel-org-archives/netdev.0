From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bogus MSG_PEEK test in rxrpc_recvmsg()
Date: Sun, 15 Mar 2015 22:20:36 -0400 (EDT)
Message-ID: <20150315.222036.345825196151430543.davem@davemloft.net>
References: <20150314053456.GT29656@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dhowells@redhat.com
To: viro@ZenIV.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53311 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751848AbbCPCUi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 22:20:38 -0400
In-Reply-To: <20150314053456.GT29656@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Sat, 14 Mar 2015 05:34:56 +0000

> [I would really like an ACK on that one from dhowells; it appears to be
> quite straightforward, but...]
> 
> MSG_PEEK isn't passed to ->recvmsg() via msg->msg_flags; as the matter of
> fact, neither the kernel users of rxrpc, nor the syscalls ever set that bit
> in there.  It gets passed via flags; in fact, another such check in the same
> function is done correctly - as flags & MSG_PEEK.
> 
> It had been that way (effectively disabled) for 8 years, though, so the patch
> needs beating up - that case had never been tested.  If it is correct, it's
> -stable fodder.
> 
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>

Also applied and queued up for -stable, thanks Al.
