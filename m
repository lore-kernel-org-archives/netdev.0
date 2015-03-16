From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix MSG_OOB test in caif_seqpkt_recvmsg()
Date: Sun, 15 Mar 2015 22:20:25 -0400 (EDT)
Message-ID: <20150315.222025.1266316541623780598.davem@davemloft.net>
References: <20150314052221.GS29656@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sjur.brandeland@stericsson.com
To: viro@ZenIV.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53306 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751638AbbCPCU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 22:20:27 -0400
In-Reply-To: <20150314052221.GS29656@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Sat, 14 Mar 2015 05:22:21 +0000

> 	It should be checking flags, not msg->msg_flags.  It's ->sendmsg()
> instances that need to look for that in ->msg_flags, ->recvmsg() ones
> (including the other ->recvmsg() instance in that file, as well as
> unix_dgram_recvmsg() this one claims to be imitating) check in flags.
> Braino had been introduced in commit dcda13 ("caif: Bugfix - use MSG_TRUNC
> in receive") back in 2010, so it goes quite a while back.
> 
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>

Applied and queued up for -stable.
