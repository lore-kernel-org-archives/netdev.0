From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next] netdevice: shrink size of struct netdev_queue
Date: Mon, 02 May 2016 22:51:56 -0400 (EDT)
Message-ID: <20160502.225156.2145114185490735551.davem@davemloft.net>
References: <1462238949-3271-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39191 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932239AbcECCv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 22:51:59 -0400
In-Reply-To: <1462238949-3271-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Tue,  3 May 2016 03:29:09 +0200

> - trans_timeout is incremented when tx queue timed out (tx watchdog).
> - tx_maxrate is set via sysfs
> 
> Moving tx_maxrate to read-mostly part shrinks the struct by 64 bytes.
> While at it, also move trans_timeout (it is out-of-place in the
> 'write-mostly' part).
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied, thanks Florian.
