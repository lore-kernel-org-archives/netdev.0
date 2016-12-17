From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: sctp_transport_lookup_process should
 rcu_read_unlock when transport is null
Date: Sat, 17 Dec 2016 11:25:21 -0500 (EST)
Message-ID: <20161217.112521.863936916212574024.davem@davemloft.net>
References: <3d4f0205d5b5c64d372dffb37602f48e4a173612.1481814352.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41310 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932162AbcLQQZX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2016 11:25:23 -0500
In-Reply-To: <3d4f0205d5b5c64d372dffb37602f48e4a173612.1481814352.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Thu, 15 Dec 2016 23:05:52 +0800

> Prior to this patch, sctp_transport_lookup_process didn't rcu_read_unlock
> when it failed to find a transport by sctp_addrs_lookup_transport.
> 
> This patch is to fix it by moving up rcu_read_unlock right before checking
> transport and also to remove the out path.
> 
> Fixes: 1cceda784980 ("sctp: fix the issue sctp_diag uses lock_sock in rcu_read_lock")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied and queued up for -stable, thanks.
